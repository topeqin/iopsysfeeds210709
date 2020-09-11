#
# Copyright (C) 2020 IOPSYS Software Solutions AB
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wfadatad
PKG_VERSION:=2.2.3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=e97075f80fe5e43e6b5f1e8253c1a87ddd72b0b5
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/wfadatad.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=PROPRIETARY IOPSYS
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/wfadatad
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WiFi Data Elements-1.0 Agent
  DEPENDS:=+libwifi +libuci +libubox +ubus +libpthread +libnl-genl \
	  +!WFA_DELM_STANDALONE:map-agent +WFA_DELM_MULTIAP_MODE:libmaputils
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
	$(INSTALL_BIN) ./files/wfa_delm.init $(1)/etc/init.d/wfadatad
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wfadatad $(1)/usr/sbin/
else
	$(INSTALL_DIR) $(1)/usr/lib/map-plugins
	$(CP) $(PKG_BUILD_DIR)/src/wfa_delm.so $(1)/usr/lib/map-plugins
endif
endef

$(eval $(call BuildPackage,wfadatad))
