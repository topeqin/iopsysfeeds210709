#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_RELEASE:=1
PKG_VERSION:=0.3
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/libpicoevent.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f446f186102539cceedaa15a95a33547ac3c1fd7
PKG_NAME:=libpicoevent

PKG_LICENSE:=LGPL-2.1-only
PKG_LICENSE_FILES:=LICENSE
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip

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
