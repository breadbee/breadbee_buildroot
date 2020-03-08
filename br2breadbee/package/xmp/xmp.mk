################################################################################
#
# xmp
#
################################################################################

XMP_VERSION = 1bd65c89248e464ad679fff8b1e488d52b4306ce
XMP_SITE = https://github.com/cmatsuoka/xmp-cli.git
XMP_SITE_METHOD = git
XMP_LICENSE = GPL-2.0
XMP_LICENSE_FILES = COPYING
XMP_AUTORECONF = YES
XMP_DEPENDS = libxmp

$(eval $(autotools-package))

