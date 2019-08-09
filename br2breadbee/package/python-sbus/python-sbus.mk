################################################################################
#
# python-sbus
#
################################################################################

PYTHON_SBUS_VERSION = 0.1
PYTHON_SBUS_SITE = https://github.com/fifteenhex/python-sbus.git
PYTHON_SBUS_SITE_METHOD = git
PYTHON_SBUS_LICENSE = BSD-3-Clause
PYTHON_SBUS_LICENSE_FILES = LICENSE
PYTHON_SBUS_DEPENDENCIES = python-serial-asyncio
PYTHON_SBUS_SETUP_TYPE = setuptools

$(eval $(python-package))
