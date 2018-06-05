#
# Copyright (C) 2018 Inteno
#

include $(TOPDIR)/rules.mk

PKG_NAME:=imonitor
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_SOURCE_PROTO=git
PKG_SOURCE_URL:=http://public.inteno.se/imonitor.git
PKG_SOURCE_VERSION:=532f4900862bcb45d8cd4bf37555fabda81750b6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=${PKG_NAME}-${PKG_VERSION}
PKG_MAINTAINER:=Sartura Support for Inteno <support-inteno@sartura.hr>
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/imonitor
	CATEGORY:=Utilities
	TITLE:=Inteno process supervisor
	DEPENDS:=+ubox +uci +ubus +rpcd +rpcd-mod-file
endef

define Package/imonitor/description
	imonitor is a process supervisor or a process control system similar to the Supervisor (http://supervisord.org/)
endef

define Package/imonitor/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/imonitor $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
endef

$(eval $(call BuildPackage,imonitor))
