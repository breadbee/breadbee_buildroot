################################################################################
#
# breadbee-overlays
#
################################################################################

BREADBEE_OVERLAYS_VERSION = 1.0
BREADBEE_OVERLAYS_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/breadbee-overlays
BREADBEE_OVERLAYS_SITE_METHOD = local
BREADBEE_OVERLAYS_LICENSE = GPLv3
BREADBEE_OVERLAYS_INSTALL_IMAGES = YES
BREADBEE_OVERLAYS_DEPENDENCIES = host-dtc

define BREADBEE_OVERLAYS_BUILD_CMDS
	$(@D)/build.py \
		--cpp=$(HOST_DIR)/bin/arm-linux-cpp \
		--bindings=$(@D)/../linux-msc313e_dev_v5_6/include/ \
		--dtc=$(HOST_DIR)/bin/dtc \
		--overlays=$(@D)/dts/ \
		--imggenoutputs=$(BINARIES_DIR)/breadbee-overlays/
endef

$(eval $(generic-package))
