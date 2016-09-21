#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_RELEASE:=1
PKG_VERSION:=1.1.0
PKG_SOURCE_URL:=http://public.inteno.se:/dectmngr2
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=ee63f0c087840adba9d944ae31d71a3ef9d64043
PKG_NAME:=dectmngr2


RSTRIP:=true
export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/dectmngr2
  CATEGORY:=Utilities
  TITLE:=Dectmngr2
  URL:=
  DEPENDS:= +natalie-dect-h bcmkernel +libubox +ubus
endef

define Package/dectmngr2/description
	Dectmngr2
endef


define Package/dectmngr2/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/dect/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d/

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dectmngr2 $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/target.bin $(1)/etc/dect/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/nvs_default $(1)/etc/dect/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/dect $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/dectmngr-wrapper.sh $(1)/usr/sbin/
	$(CP) ./files/dect.config $(1)/etc/config/dect
endef

$(eval $(call BuildPackage,dectmngr2))
