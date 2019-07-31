################################################################################
#
# flasher
#
################################################################################

FLASHER_VERSION = 1.0
FLASHER_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/flasher
FLASHER_SITE_METHOD = local
FLASHER_LICENSE = GPLv3

define FLASHER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/flasher.sh $(TARGET_DIR)/sbin/
endef

$(eval $(generic-package))
