#
# Copyright (C) 2016 Inteno
#

include $(TOPDIR)/rules.mk

PKG_NAME:=inteno-netmodes
PKG_VERSION:=0.1.0

PKG_SOURCE_VERSION:=8c97bebc03c1c61553c30b9fcdcd63bf9abe439d
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/netmoded

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/inteno-netmodes
	CATEGORY:=Base system
	DEPENDS:=+fping +ubus +libubox
	TITLE:=Predefined Network Modes
endef

define Package/inteno-netmodes/description
	Predefined Network Modes
endef

define Package/inteno-netmodes/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,inteno-netmodes))
