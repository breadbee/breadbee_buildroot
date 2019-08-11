################################################################################
#
# python-sbus
#
################################################################################

PYTHON_SBUS_VERSION = dev
PYTHON_SBUS_SITE = https://github.com/fifteenhex/python-sbus.git
PYTHON_SBUS_SITE_METHOD = git
PYTHON_SBUS_LICENSE = GPLv3
PYTHON_SBUS_LICENSE_FILES = LICENSE
PYTHON_SBUS_DEPENDENCIES = python-serial-asyncio
PYTHON_SBUS_SETUP_TYPE = setuptools

$(eval $(python-package))
