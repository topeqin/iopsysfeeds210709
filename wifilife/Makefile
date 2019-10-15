#
# Copyright (C) 2019 IOPSYS Software Solutions AB
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifilife
PKG_VERSION:=2.5.0
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=e875c8060eae9d83d4dc35aea2c9dde7c80df0df
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>

ifeq ($(CONFIG_WIFILIFE_OPEN),y)
TARGET_PROD=$(shell echo $(CONFIG_TARGET_BOARD) | sed s/\"//g)
PKG_SOURCE_URL:=http://download.iopsys.eu/iopsys/opensdk/
PKG_SOURCE:=$(PKG_NAME)-$(TARGET_PROD)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
else
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/wifilife.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
endif

include $(INCLUDE_DIR)/package.mk

define Package/wifilife
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WiFi multi-AP Controller/Agent
  DEPENDS:=+libwifi +libuci +libubox +ubus
endef

define Package/wifilife/description
 This package manages wifi in multi-AP deployment.
 Supports smart steering of WiFi clients based on
 802.11k,v and r.
endef

define Package/wifilife/config
	source "$(SOURCE)/Config.in"
endef

ifeq ($(CONFIG_WIFILIFE_OPEN),y)
define Build/Compile
endef
endif

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src

define Package/wifilife/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) -r ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wifiagent $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wificntlr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,wifilife))
