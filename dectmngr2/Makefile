#
# Copyright (C) 2019 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_RELEASE:=1
PKG_VERSION:=1.3.0
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/dectmngr.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=2c8990fd5275d469e8ab6c7a99e17fe0a56052ea
PKG_NAME:=dectmngr2

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

RSTRIP:=true
export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dectmngr2
  CATEGORY:=Utilities
  TITLE:=Dectmngr2
  URL:=
  DEPENDS:= +natalie-dect-h bcmkernel +libubox +ubus +libpicoevent endptmngr
endef

define Package/dectmngr2/description
	Dectmngr2
endef


define Package/dectmngr2/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/dect/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults/

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dectmngr2 $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/target.bin $(1)/etc/dect/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/nvs_default $(1)/etc/dect/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/dect $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/dectmngr-wrapper.sh $(1)/usr/sbin/
	$(CP) ./files/dect.config $(1)/etc/config/dect
	$(CP) ./files/etc/uci-defaults/* $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,dectmngr2))
