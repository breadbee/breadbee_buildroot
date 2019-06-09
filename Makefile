BUILDROOT_PATH=./buildroot
BUILDROOT_ARGS=BR2_DEFCONFIG=../br2breadbee/configs/breadbee_defconfig \
	BR2_DL_DIR=../dl \
	BR2_EXTERNAL="../br2autosshkey ../br2breadbee"

all: upload

dldir:
	mkdir -p ./dl

buildroot_config:
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) menuconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) savedefconfig

buildroot: dldir
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS)

.PHONY: upload


upload: buildroot
	scp buildroot/output/images/nor-16.img tftp:/srv/tftp/nor-16.img.breadbee
	scp buildroot/output/images/rootfs.squashfs tftp:/srv/tftp/rootfs.msc313e

clean:
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) clean

clean_uboot:
	git -C dl/uboot/git pull --force origin msc313
	rm dl/uboot/uboot-msc313.tar.gz
	rm -rf buildroot/output/build/uboot-msc313/

clean_kernel:
	git -C dl/linux/git pull --force origin msc313e
	rm dl/linux/linux-msc313e.tar.gz
	rm -rf buildroot/output/build/linux-msc313e/

