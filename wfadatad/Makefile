#
# Copyright (C) 2021 IOPSYS Software Solutions AB
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wfadatad
PKG_VERSION:=3.3.4

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=eb407bc5bb51e9d39f4a7bf2a02d05f6730a52a1
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/wfadatad.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=PROPRIETARY IOPSYS
PKG_LICENSE_FILES:=LICENSE


PKG_BUILD_DEPENDS:=map-plugin

include $(INCLUDE_DIR)/package.mk

define Package/wfadatad
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WiFi Data Elements-1.0 Agent and Collector
  DEPENDS:=+libwifi +libuci +libubox +ubus +libpthread +libnl-genl \
	  +!WFA_DELM_STANDALONE:map-agent +libieee1905 +map-plugin
endef

define Package/wfadatad/description
 This package implements WiFi Alliance's Data Elements v.1.0.
 It collects WiFi network's diagnostic data and reports them
 to the Data Elements Collector.
 In Data Elements Agent mode, the package by default is built
 as a loadable plugin module to the MultiAP Agent.
 The package can also be built as a standalone daemon running
 independently of a MultiAP Agent.
endef


define Package/wfadatad/config
	source "$(SOURCE)/Config.in"
endef


ifeq ($(CONFIG_WFA_DELM_STANDALONE),y)
MAKE_FLAGS += CONFIG_WFA_DELM_STANDALONE=y
endif

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src


define Package/wfadatad/install

ifeq ($(CONFIG_WFA_DELM_STANDALONE),y)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/wfadatad.init $(1)/etc/init.d/wfadatad
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wfadatad $(1)/usr/sbin/
else
	$(INSTALL_DIR) $(1)/usr/lib/map-plugins
	$(CP) $(PKG_BUILD_DIR)/src/wfa_delm.so $(1)/usr/lib/map-plugins
endif
endef

$(eval $(call BuildPackage,wfadatad))
