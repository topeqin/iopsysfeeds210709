#
# Copyright (C) 2020-21 IOPSYS Software Solutions AB
#

include $(TOPDIR)/rules.mk

PKG_NAME:=map-agent
PKG_VERSION:=5.0.1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=7e7706605bf4edf9223dc0b039f417143271a7cd
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>

PKG_LICENSE:=PROPRIETARY IOPSYS
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/map-agent.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=skip

PKG_BUILD_DEPENDS:=map-plugin

include $(INCLUDE_DIR)/package.mk

define Package/map-agent
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WiFi multi-AP Agent (EasyMesh R2)
  DEPENDS:=+libwifi +libuci +libubox +ubus +libeasy +libieee1905 +ieee1905 \
	  +map-plugin
endef

define Package/map-agent/description
 This package implements EasyMesh R2 compliant WiFi Agent.
endef

define Package/map-agent/config
	#source "$(SOURCE)/Config.in"
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src

define Package/map-agent/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mapagent $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,map-agent))
