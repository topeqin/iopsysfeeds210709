#
# Copyright (C) 2019 iopsys
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netmode
PKG_VERSION:=0.2.0

PKG_SOURCE_VERSION:=5c8abbdf86e4651c7c6f14f784cfb52e69979f96
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/netmoded
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/netmode
	CATEGORY:=Base system
	DEPENDS:=+fping +ubus +libubox +libuci
	TITLE:=Predefined Network Modes
endef

define Package/netmode/description
	Predefined Network Modes
endef

define Package/netmode/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/netmoded $(1)/sbin/
endef

$(eval $(call BuildPackage,netmode))
