#
# Copyright (C) 2016 Inteno
#

include $(TOPDIR)/rules.mk

PKG_NAME:=inteno-netmodes
PKG_VERSION:=0.2.0

PKG_SOURCE_VERSION:=155aa7dad052b37f081683ad9cf366d39a03f4d7
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/netmoded

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/inteno-netmodes
	CATEGORY:=Base system
	DEPENDS:=+fping +ubus +libubox +libuci
	TITLE:=Predefined Network Modes
endef

define Package/inteno-netmodes/description
	Predefined Network Modes
endef

define Package/inteno-netmodes/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/netmoded $(1)/sbin/
endef

$(eval $(call BuildPackage,inteno-netmodes))
