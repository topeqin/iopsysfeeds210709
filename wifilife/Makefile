#
# Copyright (C) 2018 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifilife
PKG_VERSION:=1.0.2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=a9c2106bf53a4e9f5e1a773cbda0af7e54e83a09
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>

ifeq ($(CONFIG_WIFILIFE_OPEN),y)
TARGET_PROD=$(shell echo $(CONFIG_TARGET_BOARD) | sed s/\"//g)
PKG_SOURCE_URL:=http://iopsys.inteno.se/iopsys/consumer/
PKG_SOURCE:=$(PKG_NAME)-$(TARGET_PROD)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
else
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/wifilife.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(BASE_PKG_VERSION)
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

ifeq ($(CONFIG_WIFILIFE_OPEN),y)
define Build/Compile
endef
define Package/wifilife/install
endef
else
TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src

define Package/wifilife/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wifilife.init $(1)/etc/init.d/wifilife
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wifiagent $(1)/usr/sbin/
endef
endif

$(eval $(call BuildPackage,wifilife))
