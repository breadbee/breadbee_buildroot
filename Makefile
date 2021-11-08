PREFIX=breadbee
TOOLCHAIN=arm-buildroot-linux-gnueabihf_sdk-buildroot.tar.gz
EXTERNALS=../br2autosshkey ../br2sanetime ../br2breadbee ../br2apps
DEFCONFIG=../br2breadbee/configs/breadbee_defconfig
DEFCONFIG_RESCUE=../br2breadbee/configs/breadbee_rescue_defconfig

# main buildroot variables
BUILDROOT_PATH=./buildroot
BUILDROOT_ARGS=BR2_DEFCONFIG=../br2breadbee/configs/breadbee_defconfig \
	BR2_DL_DIR=$(DLDIR) \
	BR2_EXTERNAL="../br2autosshkey ../br2sanetime ../br2breadbee ../br2apps"

PKGS_BB=$(foreach dir,$(wildcard br2breadbee/package/*/),$(shell basename $(dir)))
PKGS_APPS=$(foreach dir,$(wildcard br2apps/package/*/),$(shell basename $(dir)))

UBOOT_BRANCH=mstar

LINUX_BRANCH := $(shell cat br2breadbee/configs/breadbee_defconfig | grep BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION | cut -d "=" -f 2 | sed s/\"//g)

# try to guess the interface for tftp
ifeq ($(TFTP_INTERFACE),)
	TFTP_INTERFACE=$(shell ip addr | grep BROADCAST | grep -v "docker" | head -n 1 | cut -d ":" -f 2 | tr -d '[:space:]')
endif
IP_ADDR=$(shell ip addr | grep -A 2 $(TFTP_INTERFACE) | grep -Po '(?<=inet )([1-9]{1,3}\.){3}[1-9]{1,3}')

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

.PHONY: buildindocker \
	run_tftpd \
	linux_update \
	linux_clean \
	linux_rescue_clean \
	uboot_update \
	upload

all: buildroot buildroot-rescue copy-outputs

bootstrap.stamp:
	git submodule init
	git submodule update
	touch bootstrap.stamp

./br2secretsauce/common.mk: bootstrap.stamp
./br2secretsauce/rescue.mk: bootstrap.stamp

bootstrap: bootstrap.stamp

include ./br2secretsauce/common.mk
include ./br2secretsauce/rescue.mk

#buildroot: $(OUTPUTS) $(DLDIR)
#	$(call clean_localpkgs,$(BUILDROOT_PATH))
#	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
#	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS)

clean: buildroot-clean buildroot-rescue-clean
	rm -rf $(OUTPUTS)

uboot_clean:
	$(call clean_pkg,$(BUILDROOT_PATH),uboot-msc313)

run_tftpd:
	@echo "Running TFTP on $(TFTP_INTERFACE), ip is $(IP_ADDR)."
	@echo "Run \"setenv serverip $(IP_ADDR)\" in u-boot before running any tftp commands."
	@echo "Hit ctrl-c to stop."
#	@sudo ./buildroot/output/host/bin/ptftpd $(TFTP_INTERFACE) -r $(OUTPUTS)
	@sudo ./buildroot/output/host/usr/sbin/in.tftpd -v -s -L $(OUTPUTS)

buildindocker:
	docker build -t breadbee_buildroot .
	docker run -v $(shell pwd):/breadbee_buildroot -t breadbee_buildroot sh -c "cd /breadbee_buildroot && make"

copy-outputs:
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/nor-16.img)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/kernel.fit)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/u-boot.bin)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/u-boot.img)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/ipl)
	$(call copy_to_outputs,$(BUILDROOT_PATH)/output/images/rootfs.squashfs)
	$(call copy_to_outputs,$(BUILDROOT_RESCUE_PATH)/output/images/kernel.fit,rescue.fit)

upload:
	$(call upload_to_tftp_with_scp,$(BUILDROOT_PATH)/output/images/kernel.fit)
	$(call upload_to_tftp_with_scp,$(BUILDROOT_PATH)/output/images/rootfs.squashfs)
	$(call upload_to_tftp_with_scp,$(BUILDROOT_PATH)/output/images/nor-16.img)
