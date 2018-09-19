#
# Copyright (C) 2018 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifilife
PKG_VERSION:=1.0.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=2c7247a3e9813cd32255980505bfbd4318e225c7
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/wifilife.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

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

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src

define Package/wifilife/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wifiagent $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/wifiagent.config $(1)/etc/config/wifiagent
endef

$(eval $(call BuildPackage,wifilife))
