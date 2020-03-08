################################################################################
#
# libxmp
#
################################################################################

LIBXMP_VERSION = 92313f6f525a8510a2492df4266abcf8f0b45834
LIBXMP_SITE = https://github.com/cmatsuoka/libxmp.git
LIBXMP_SITE_METHOD = git
LIBXMP_LICENSE = GPL-2.0
LIBXMP_LICENSE_FILES = COPYING
LIBXMP_AUTORECONF = YES
LIBXMP_INSTALL_STAGING = YES

$(eval $(autotools-package))

