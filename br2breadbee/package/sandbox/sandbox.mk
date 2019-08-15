################################################################################
#
# sandbox
#
################################################################################

SANDBOX_VERSION = 1.0
SANDBOX_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/sandbox
SANDBOX_SITE_METHOD = local
SANDBOX_LICENSE = GPLv3

define SANDBOX_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 $(@D)/S22sandbox.nfs $(TARGET_DIR)/etc/init.d/S22sandbox
endef

define SANDBOX_INSTALL_TARGET_CMDS
	echo "NFS_VOLUME=$(BR2_PACKAGE_SANDBOX_NFS_VOLUME)" > $(TARGET_DIR)/etc/sandbox.conf
	mkdir -p $(TARGET_DIR)/sandbox
endef

$(eval $(generic-package))
