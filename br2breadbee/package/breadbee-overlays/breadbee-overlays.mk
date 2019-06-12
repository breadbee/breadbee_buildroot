################################################################################
#
# breadbee-overlays
#
################################################################################

BREADBEE_OVERLAYS_VERSION = 1.0
BREADBEE_OVERLAYS_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/breadbee-overlays
BREADBEE_OVERLAYS_SITE_METHOD = local
BREADBEE_OVERLAYS_LICENSE = BSD-3-Clause
BREADBEE_OVERLAYS_INSTALL_IMAGES = YES

define BREADBEE_OVERLAYS_INSTALL_DTB_OVERLAYS
        for ovl in  $(@D)/*.dts; do \
		dtc -I dts -O dtb -o $(@D)/$$(basename "$$ovl" .dts).dtb $${ovl}; \
        done
	rm -f $(BINARIES_DIR)/breadbee-overlays/fdtlist
	rm -f $(BINARIES_DIR)/breadbee-overlays/configlist
	off=587235328; for ovldtb in  $(@D)/*.dtb; do \
		$(INSTALL) -D -m 0644 $${ovldtb} $(BINARIES_DIR)/breadbee-overlays/$${ovldtb##*/}; \
		echo -e "$$(basename "$$ovldtb" .dtb)_overlay {\n"\
			" data = /incbin/(\"$${ovldtb}\");\n" \
			" type = \"flat_dt\";\n" \
			" arch = \"arm\";\n" \
			" compression = \"none\";\n" \
			" load = <$${off}>;\n" \
			" hash@0 {\n" \
			"  algo = \"crc32\";\n" \
			" };\n" \
                        " hash@1 {\n" \
			"  algo = \"sha1\";\n" \
			" };\n" \
			"};\n\n" >> $(BINARIES_DIR)/breadbee-overlays/fdtlist; \
		echo -e "$$(basename "$$ovldtb" .dtb) {\n"\
			" fdt = \"$$(basename "$$ovldtb" .dtb)_overlay\";\n" \
			"};\n" >> $(BINARIES_DIR)/breadbee-overlays/configlist; \
		dtbsz=`stat --printf="%s" $${ovldtb}`; off=$$(($${off}+$${dtbsz})); \
	done
endef

define BREADBEE_OVERLAYS_INSTALL_IMAGES_CMDS
	$(BREADBEE_OVERLAYS_INSTALL_DTB_OVERLAYS)
endef

$(eval $(generic-package))
