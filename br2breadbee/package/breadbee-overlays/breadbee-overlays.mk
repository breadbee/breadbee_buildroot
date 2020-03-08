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

BREADBEE_OVERLAYS_CATEGORIES =

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_ADC),y)
BREADBEE_OVERLAYS_CATEGORIES += adc
endif

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_FPGA),y)
BREADBEE_OVERLAYS_CATEGORIES += fpga
endif

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_IR),y)
BREADBEE_OVERLAYS_CATEGORIES += ir
endif

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_PWM),y)
BREADBEE_OVERLAYS_CATEGORIES += pwm
endif

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_SPI),y)
BREADBEE_OVERLAYS_CATEGORIES += spi
endif

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_SD),y)
BREADBEE_OVERLAYS_CATEGORIES += sd
endif

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_UART),y)
BREADBEE_OVERLAYS_CATEGORIES += uart
endif

ifeq ($(BR2_PACKAGE_BREADBEE_OVERLAYS_USB),y)
BREADBEE_OVERLAYS_CATEGORIES += usb
endif

define BREADBEE_OVERLAYS_BUILD_CMDS
	$(@D)/build.py \
		--cpp=$(HOST_DIR)/bin/arm-linux-cpp \
		--bindings=$(@D)/../linux-msc313e_dev_v5_6/include/ \
		--dtc=$(HOST_DIR)/bin/dtc \
		--overlays=$(@D)/dts/ \
		--imggenoutputs=$(BINARIES_DIR)/breadbee-overlays/ \
		--beecfg_outputs=$(@D)/usr/share/breadbee-overlays/ \
		$(BREADBEE_OVERLAYS_CATEGORIES)
endef

$(eval $(generic-package))
