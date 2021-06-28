#
# Copyright (C) 2020 IOPSYS Software Solutions AB
#

include $(TOPDIR)/rules.mk

PKG_NAME:=map-agent
PKG_VERSION:=4.0.15
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=054529c9c516a81209242a20bf370f06ea17ac46
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

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/map-agent
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/include/*.h $(1)/usr/include/map-agent
	$(CP) $(PKG_BUILD_DIR)/src/utils/timer_impl.h $(1)/usr/include/map-agent
	$(CP) $(PKG_BUILD_DIR)/src/utils/*.so* $(1)/usr/lib/
endef

define Package/map-agent/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/src/utils/*.so* $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mapagent $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,map-agent))
