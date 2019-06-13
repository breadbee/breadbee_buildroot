################################################################################
#
# ptftpd
#
################################################################################

PTFTPD_VERSION = 044bfda74384a9590e0cffd75f8e339e7fe8ec21
PTFTPD_SITE = https://github.com/fifteenhex/ptftpd.git
PTFTPD_SITE_METHOD = git
PTFTPD_SETUP_TYPE = setuptools
PTFTPD_DEPENDENCIES = python-netifaces

$(eval $(host-python-package))
