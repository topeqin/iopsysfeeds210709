#
# Copyright (C) 2018 Inteno
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rulengd
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_SOURCE_PROTO=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/rulengd.git
PKG_SOURCE_VERSION:=99881f39232154530ac129dc2109d78963017ad1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=${PKG_NAME}-${PKG_VERSION}
PKG_MAINTAINER:=Sartura Support for Inteno <support-inteno@sartura.hr>
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rulengd
	CATEGORY:=Utilities
	TITLE:=RuleEngine daemon
	DEPENDS:=+ubox +uci +ubus +libjson-c
	MENU:=1
endef

define Package/rulengd/description
	rulengd listens for events and executes speficied methods if the incoming event arguments contain speficied ones.
endef

define Package/rulengd/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rulengd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
endef

$(eval $(call BuildPackage,rulengd))
