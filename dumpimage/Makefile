#
# Copyright (C) 2021 IOPSYS Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=dumpimage
PKG_RELEASE:=1
PKG_VERSION:=1.0

PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/dumpimage.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=b70c60b751e22d8286028fed3c7bfbf4b576cbf0
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

RSTRIP:=true
export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	CATEGORY:=Utilities
	TITLE:=dumpimage
	DEPENDS:= +libfdt
endef

define Package/$(PKG_NAME)/description
	Command to extract sub images from FIT images.
endef

MAKE_FLAGS += \
	CFLAGS+="-Wall"

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dumpimage $(1)/usr/sbin/
	$(STRIP) $(1)/usr/sbin/dumpimage
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
