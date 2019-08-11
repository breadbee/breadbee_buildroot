################################################################################
#
# python-tinyodrive
#
################################################################################

PYTHON_TINYODRIVE_VERSION = dev
PYTHON_TINYODRIVE_SITE = https://github.com/fifteenhex/python-tinyodrive.git
PYTHON_TINYODRIVE_SITE_METHOD = git
PYTHON_TINYODRIVE_LICENSE = GPLv3
PYTHON_TINYODRIVE_LICENSE_FILES = LICENSE
PYTHON_TINYODRIVE_DEPENDENCIES = python-serial-asyncio
PYTHON_TINYODRIVE_SETUP_TYPE = setuptools

$(eval $(python-package))
