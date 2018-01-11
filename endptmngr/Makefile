#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_RELEASE:=1
PKG_VERSION:=0.1
PKG_SOURCE_URL:=git@private.inteno.se:endptmngr
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f9e1dcfce3a5745a91b70dcc04c0209177f99683
PKG_NAME:=endptmngr

RSTRIP:=true
export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/endptmngr
  CATEGORY:=Utilities
  TITLE:=Brcmslic
  URL:=
  DEPENDS:= +libubox +ubus +libpicoevent
endef

define Package/endptmngr/description
	endptmngr
endef

define Package/endptmngr/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d/
	cp $(PKG_BUILD_DIR)/files/etc/init.d/* $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/endptmngr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,endptmngr))
