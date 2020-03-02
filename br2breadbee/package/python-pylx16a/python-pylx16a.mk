################################################################################
#
# python-pylx16a
#
################################################################################

PYTHON_PYLX16A_VERSION = 98a6fae3b2183cb189a998fd847131ae0a6aea55
PYTHON_PYLX16A_SITE = https://github.com/fifteenhex/PyLX-16A.git
PYTHON_PYLX16A_SITE_METHOD = git
PYTHON_PYLX16A_LICENSE = MIT
PYTHON_PYLX16A_LICENSE_FILES = LICENSE
PYTHON_PYLX16A_DEPENDENCIES = python-serial
PYTHON_PYLX16A_SETUP_TYPE = setuptools

$(eval $(python-package))
