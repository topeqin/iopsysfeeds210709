#
# Copyright (C) 2018 iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=imonitor
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_SOURCE_PROTO=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/imonitor.git
PKG_SOURCE_VERSION:=4beb1d5d6925507f1850a84c0b83aaf12a082f7f
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=${PKG_NAME}-${PKG_VERSION}
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/imonitor
	CATEGORY:=Utilities
	TITLE:=iopsysWrt process supervisor
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
