#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_RELEASE:=1
PKG_VERSION:=0.1
PKG_SOURCE_URL:=http://public.inteno.se/libpicoevent
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c96770b32f66c6e799f8430d8e85d94780358135
PKG_NAME:=libpicoevent

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/libpicoevent
  CATEGORY:=Libraries
  TITLE:=Libpicoevent
  URL:=
  DEPENDS:=
endef

define Package/libpicoevent/description
	Minimal event library
endef

define Package/libpicoevent/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/libpicoevent.h $(STAGING_DIR)/usr/include
	$(CP) $(PKG_BUILD_DIR)/libpicoevent.so $(STAGING_DIR)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libpicoevent.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,libpicoevent))
