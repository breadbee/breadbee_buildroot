#main buildroot variables
BUILDROOT_PATH=./buildroot
BUILDROOT_ARGS=BR2_DEFCONFIG=../br2breadbee/configs/breadbee_defconfig \
	BR2_DL_DIR=../dl \
	BR2_EXTERNAL="../br2autosshkey ../br2sanetime ../br2breadbee"

#rescue buildroot path
BUILDROOT_RESCUE_PATH=./buildroot_rescue
BUILDROOT_RESCUE_ARGS=BR2_DEFCONFIG=../br2breadbee/configs/breadbee_rescue_defconfig \
	BR2_DL_DIR=../dl \
	BR2_EXTERNAL="../br2autosshkey ../br2sanetime ../br2breadbee"

ifeq ($(TFTP_INTERFACE),)
	TFTP_INTERFACE=$(shell ip addr | grep BROADCAST | grep -v "docker" | head -n 1 | cut -d ":" -f 2 | tr -d '[:space:]')
endif
IP_ADDR=$(shell ip addr | grep -A 2 $(TFTP_INTERFACE) | grep -Po '(?<=inet )([1-9]{1,3}\.){3}[1-9]{1,3}')


.PHONY: bootstrap upload run_tftpd update_linux update_uboot

all: buildroot buildroot_rescue

bootstrap:
	git submodule init
	git submodule update

dldir:
	mkdir -p ./dl

outputdir:
	mkdir -p ./outputs

clean_localpkgs:
	rm -rf buildroot/output/build/breadbee-overlays-*/
	rm -rf buildroot/output/build/beecfg-*/

buildroot_config:
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) menuconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) savedefconfig

buildroot_clean:
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) clean

buildroot: outputdir dldir clean_localpkgs
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS)
	cp $(BUILDROOT_PATH)/output/images/nor-16.img ./outputs
	cp $(BUILDROOT_PATH)/output/images/kernel.fit.img ./outputs
	cp $(BUILDROOT_PATH)/output/images/u-boot.bin ./outputs
	cp $(BUILDROOT_PATH)/output/images/u-boot.img ./outputs
	cp $(BUILDROOT_PATH)/output/images/u-boot-spl.bin ./outputs
	cp $(BUILDROOT_PATH)/output/images/rootfs.squashfs ./outputs


buildroot_rescue_config:
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) menuconfig
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) savedefconfig

buildroot_rescue: outputdir dldir clean_localpkgs
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS)
	cp $(BUILDROOT_RESCUE_PATH)/output/images/kernel.fit.img ./outputs/rescue.fit.img

buildroot_rescue_clean:
	$(MAKE) -C $(BUILDROOT_RESCUE_PATH) $(BUILDROOT_RESCUE_ARGS) clean

upload: buildroot
	scp buildroot/output/images/nor-16.img tftp:/srv/tftp/nor-16.img.breadbee
	scp buildroot/output/images/rootfs.squashfs tftp:/srv/tftp/rootfs.msc313e

clean: buildroot_clean buildroot_rescue_clean
	rm -rf outputdir

update_uboot:
	git -C dl/uboot/git fetch --all
	git -C dl/uboot/git reset --hard origin/msc313
	git -C dl/uboot/git clean -fd
	rm -f dl/uboot/uboot-msc313.tar.gz
	rm -rf $(BUILDROOT_PATH)/output/build/uboot-msc313/

update_linux:
	git -C dl/linux/git fetch --all
	git -C dl/linux/git reset --hard origin/msc313e
	git -C dl/linux/git clean -fd
	rm -f dl/linux/linux-msc313e.tar.gz
	rm -rf $(BUILDROOT_RESCUE_PATH)/output/build/linux-msc313e/
	rm -rf $(BUILDROOT_RESCUE_PATH)/output/build/linux-msc313/

run_tftpd:
	@echo "Running TFTP on $(TFTP_INTERFACE), ip is $(IP_ADDR)."
	@echo "Run \"setenv serverip $(IP_ADDR)\" in u-boot before running any tftp commands."
	@echo "Hit ctrl-c to stop."
	@sudo ./buildroot/output/host/bin/ptftpd $(TFTP_INTERFACE) ./outputs

buildindocker:
	docker build -t breadbee_buildroot .
	docker run -v $(shell pwd):/breadbee_buildroot -t breadbee_buildroot sh -c "cd /breadbee_buildroot && make"
