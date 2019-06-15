################################################################################
#
# beecfg
#
################################################################################

BEECFG_VERSION = 1.0
BEECFG_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/beecfg
BEECFG_SITE_METHOD = local
BEECFG_LICENSE = BSD-3-Clause
BEECFG_LICENSE_FILES = LICENSE
BEECFG_DEPENDENCIES = python-dialog3
BEECFG_SETUP_TYPE = setuptools

$(eval $(python-package))
