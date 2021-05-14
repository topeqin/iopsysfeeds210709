#
# Copyright (C) 2021 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=periodicstats
PKG_VERSION:=1.0.0

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=91b15f9779baccc93213ce3ca164c326235d3096
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/periodicstats.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/periodicstats
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Periodic Statistics Daemon
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c +libbbfdm
endef

define Package/periodicstats/description
	Manage periodic statistics
endef

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
        $(CP) -rf ./periodicstats/* $(PKG_BUILD_DIR)/
endef
endif

define Package/periodicstats/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/bbfdm
	$(CP) $(PKG_BUILD_DIR)/bbf_plugin/libperiodicstats.so $(1)/usr/lib/bbfdm
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/periodicstatsd $(1)/usr/sbin
endef

$(eval $(call BuildPackage,periodicstats))
