PREFIX=breadbee
TOOLCHAIN=arm-buildroot-linux-gnueabihf_sdk-buildroot.tar.gz
EXTERNALS=../br2autosshkey ../br2sanetime ../br2breadbee ../br2apps

# main buildroot variables
BUILDROOT_PATH=./buildroot
BUILDROOT_ARGS=BR2_DEFCONFIG=../br2breadbee/configs/breadbee_defconfig \
	BR2_DL_DIR=$(DLDIR) \
	BR2_EXTERNAL="../br2autosshkey ../br2sanetime ../br2breadbee ../br2apps"

# rescue buildroot variables
BUILDROOT_RESCUE_PATH=./buildroot_rescue
BUILDROOT_RESCUE_ARGS=BR2_DEFCONFIG=../br2breadbee/configs/breadbee_rescue_defconfig \
	BR2_DL_DIR=$(DLDIR) \
	BR2_EXTERNAL="../br2autosshkey ../br2sanetime ../br2breadbee"

PKGS_BB=$(foreach dir,$(wildcard br2breadbee/package/*/),$(shell basename $(dir)))
PKGS_APPS=$(foreach dir,$(wildcard br2apps/package/*/),$(shell basename $(dir)))

UBOOT_BRANCH=mstar

LINUX_BRANCH := $(shell cat br2breadbee/configs/breadbee_defconfig | grep BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION | cut -d "=" -f 2 | sed s/\"//g)

# try to guess the interface for tftp
ifeq ($(TFTP_INTERFACE),)
	TFTP_INTERFACE=$(shell ip addr | grep BROADCAST | grep -v "docker" | head -n 1 | cut -d ":" -f 2 | tr -d '[:space:]')
endif
IP_ADDR=$(shell ip addr | grep -A 2 $(TFTP_INTERFACE) | grep -Po '(?<=inet )([1-9]{1,3}\.){3}[1-9]{1,3}')

BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
ifneq ($(BRANCH), master)
	BRANCH_PREFIX=$(BRANCH)-
endif

# this is crappy hack to get around the fact that buildroot doesn't
# really support developing in buildroot. By deleting our local stuff
# each run we don't need to keep bumping version numbers to get them
# to get built again.
define clean_localpkgs
	@echo Cleaning packages: $(PKGS_BB) $(PKGS_APPS)
	rm -rf $(foreach pkg,$(PKGS_BB),$(wildcard $(1)/output/build/$(pkg)-*/))
	rm -rf $(foreach pkg,$(PKGS_APPS),$(wildcard $(1)/output/build/$(pkg)-*/))
endef

define clean_pkg
	rm -rf $(1)/output/build/$(2)/
endef

define copy_to_outputs
	cp $(1) $(OUTPUTS)/$(addprefix $(BRANCH_PREFIX), $(if $(2),$(2),$(notdir $(1))))
endef

.PHONY: bootstrap \
	buildindocker \
	buildroot \
	buildroot_rescue \
	run_tftpd \
	linux_update \
	linux_clean \
	linux_rescue_clean \
	uboot_update

all: buildroot buildroot_rescue

bootstrap.stamp:
	git submodule init
	git submodule update
	touch bootstrap.stamp

./br2secretsauce/common.mk: bootstrap.stamp
./br2secretsauce/rescue.mk: bootstrap.stamp

bootstrap: bootstrap.stamp

include ./br2secretsauce/common.mk
include ./br2secretsauce/rescue.mk

buildroot: $(OUTPUTS) $(DLDIR)
	$(call clean_localpkgs,$(BUILDROOT_PATH))
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/nor-16.img)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/kernel.fit.img)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/u-boot.bin)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/u-boot.img)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/ipl)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/rootfs.squashfs)

buildroot_rescue_config:
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) menuconfig
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) savedefconfig

ifeq ($(BRANCH), master)
buildroot_rescue: $(OUTPUTS) $(DLDIR)
	$(call clean_localpkgs,$(BUILDROOT_RESCUE_PATH))
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS)
	$(call copy_to_outputs,$(BUILDROOT_RESCUE_PATH)/output/images/kernel.fit.img,rescue.fit.img)
else
buildroot_rescue:
	@echo "rescue is only built for master, your branch is $(BRANCH)"
endif


buildroot_rescue_clean:
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) clean

clean: buildroot_clean buildroot_rescue_clean
	rm -rf $(OUTPUTS)

uboot_update:
	$(call update_git_package,uboot,$(UBOOT_BRANCH))
	$(call clean_pkg,$(BUILDROOT_PATH),uboot-$(UBOOT_BRANCH))

uboot_clean:
	$(call clean_pkg,$(BUILDROOT_PATH),uboot-msc313)

linux_update: linux_clean linux_rescue_clean
	$(call update_git_package,linux,$(LINUX_BRANCH))

linux_clean:
	$(call clean_pkg,$(BUILDROOT_PATH),linux-$(LINUX_BRANCH))

linux_rescue_clean:
	$(call clean_pkg, $(BUILDROOT_RESCUE_PATH),linux-$(LINUX_BRANCH))

run_tftpd:
	@echo "Running TFTP on $(TFTP_INTERFACE), ip is $(IP_ADDR)."
	@echo "Run \"setenv serverip $(IP_ADDR)\" in u-boot before running any tftp commands."
	@echo "Hit ctrl-c to stop."
#	@sudo ./buildroot/output/host/bin/ptftpd $(TFTP_INTERFACE) -r $(OUTPUTS)
	@sudo ./buildroot/output/host/usr/sbin/in.tftpd -v -s -L $(OUTPUTS)

buildindocker:
	docker build -t breadbee_buildroot .
	docker run -v $(shell pwd):/breadbee_buildroot -t breadbee_buildroot sh -c "cd /breadbee_buildroot && make"
