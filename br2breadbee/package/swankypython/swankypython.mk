################################################################################
#
# swanky python
#
################################################################################

SWANKYPYTHON_VERSION = 1.0
SWANKYPYTHON_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/swankypython
SWANKYPYTHON_SITE_METHOD = local
SWANKYPYTHON_LICENSE = GPLv3

define SWANKYPYTHON_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0555 $(@D)/swankypython.sh $(TARGET_DIR)//etc/profile.d/
	$(INSTALL) -D -m 0555 $(@D)/swankypython.py $(TARGET_DIR)/usr/share/
endef

$(eval $(generic-package))
