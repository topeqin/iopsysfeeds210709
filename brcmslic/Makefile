#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_RELEASE:=1
PKG_VERSION:=0.1
PKG_SOURCE_URL:=git@private.inteno.se:brcmslic
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=4dd8c50ab8f107bd757ff7ece5f6c17b790201b3
PKG_NAME:=brcmslic


RSTRIP:=true
export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/brcmslic
  CATEGORY:=Utilities
  TITLE:=Brcmslic
  URL:=
  DEPENDS:= bcmkernel
endef

define Package/brcmslic/description
	Brcmslic
endef


define Package/brcmslic/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d/

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/brcmslic $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,brcmslic))
