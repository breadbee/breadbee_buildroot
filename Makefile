BUILDROOT_PATH=./buildroot
BUILDROOT_ARGS=BR2_DEFCONFIG=../br2breadbee/configs/breadbee_defconfig \
	BR2_DL_DIR=../dl \
	BR2_EXTERNAL="../br2autosshkey ../br2breadbee"

all: buildroot

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
	scp buildroot/output/images/rootfs.squashfs tftp:/srv/tftp/rootfs.msc313e

clean:
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) clean
