################################################################################
#
# rwsetup
#
################################################################################

RWSETUP_VERSION = 1.0
RWSETUP_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/rwsetup
RWSETUP_SITE_METHOD = local
RWSETUP_LICENSE = GPLv3

define RWSETUP_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 $(@D)/S22rwsetup $(TARGET_DIR)/etc/init.d/S22rwsetup
endef

define RWSETUP_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/rw
endef

$(eval $(generic-package))
