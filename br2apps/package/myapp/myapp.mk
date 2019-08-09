################################################################################
#
# myapp
#
################################################################################

MYAPP_VERSION = 1.0
MYAPP_SITE = $(BR2_EXTERNAL_BREADBEE_PATH)/package/myapp
MYAPP_SITE_METHOD = local
MYAPP_LICENSE = BSD-3-Clause
MYAPP_LICENSE_FILES = LICENSE
MYAPP_DEPENDENCIES = python-dialog3
MYAPP_SETUP_TYPE = setuptools

$(eval $(python-package))
