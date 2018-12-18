#
# Copyright (C) 2018 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifilife
PKG_VERSION:=1.0.2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=8de1e0f3264998a6757ae2fb16599ad6eb19a0f9
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>

ifeq ($(CONFIG_WIFILIFE_OPEN),y)
TARGET_PROD=$(shell echo $(CONFIG_TARGET_BOARD) | sed s/\"//g)
PKG_SOURCE_URL:=http://iopsys.inteno.se/iopsys/consumer/
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
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wifilife.init $(1)/etc/init.d/wifilife
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/997-wifilife-add-owsd-wifi \
				$(1)/etc/uci-defaults/997-wifilife-add-owsd-wifi
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wifiagent $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,wifilife))
