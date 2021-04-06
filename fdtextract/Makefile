#
# Copyright (C) 2021 IOPSYS Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=fdtextract
PKG_RELEASE:=1
PKG_VERSION:=1.0

PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/fdtextract.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=ccb6044a9a00d4ef0cb3175064705b6b863f02b1
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
	TITLE:=fdtextract
	DEPENDS:= +libfdt
endef

define Package/$(PKG_NAME)/description
	Command to extract sub images from FIT images.
endef

MAKE_FLAGS += \
	CFLAGS+="-Wall"

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fdtextract $(1)/usr/sbin/
	$(STRIP) $(1)/usr/sbin/fdtextract
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
