#
# Copyright (C) 2021 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ieee1905
PKG_VERSION:=3.0.4

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=b56e8d6c352265df809b484d2ce9aaa89a82270e
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/ieee1905.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=skip
endif
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk


define Package/ieee1905/Default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=IEEE-1905.1 stack
endef

define Package/ieee1905/config
  source "$(SOURCE)/Config.in"
endef

define Package/libieee1905
$(call Package/ieee1905/Default,$(1))
  TITLE+= (library for CMDU and TLV handling)
  DEPENDS= +libubox +libuci +libubus +libeasy +libnl-genl +libwifi \
	   +libjson-c +libblobmsg-json
endef

define Package/ieee1905
$(call Package/ieee1905/Default,$(1))
  TITLE+= ieee1905d (daemon implementing 1905.1 and provides cli)
  DEPENDS= +libubox +libuci +libubus +libeasy +libnl-genl +libwifi \
	   +libjson-c +libblobmsg-json +libwifi +ubus +libpthread \
	   +libnl-genl +libieee1905
endef


define Package/map-plugin
$(call Package/ieee1905/Default,$(1))
  TITLE:=Multi-AP (Easymesh) plugin
  DEPENDS= +libubox +libuci +libubus +libeasy +libnl-genl +libwifi \
	   +libjson-c +libblobmsg-json +ieee1905 +libieee1905
endef

define Package/ieee1905/description
 This package provides IEEE Std 1905.1 stack.
endef

define Package/libieee1905/description
 This package provides library functions for IEEE Std 1905.1 stack.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src


define Package/ieee1905/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/ieee1905
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ieee1905d $(1)/usr/sbin/
endef

define Package/libieee1905/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libieee1905.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/libmidgen.so $(1)/usr/lib/
endef

define Package/map-plugin/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/ieee1905
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/libmaputil.so $(1)/usr/lib/libmaputil.so
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map.so $(1)/usr/lib/ieee1905/map.so
endef

define Build/InstallDev/map-plugin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/ieee1905
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map2.h $(1)/usr/include/map22.h
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map_module.h $(1)/usr/include/map_module22.h
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map.so $(1)/usr/lib/ieee1905/map.so
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/libmaputil.so $(1)/usr/lib/libmaputil.so
endef


define Build/InstallDev/libieee1905
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/ieee1905
	$(CP) $(PKG_BUILD_DIR)/src/cmdu.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/1905_tlvs.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/i1905_wsc.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/bufutil.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/timer_impl.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/libmidgen.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/libieee1905.so $(1)/usr/lib/
endef

define Build/InstallDev
	$(call Build/InstallDev/libieee1905,$(1),$(2))
	$(call Build/InstallDev/map-plugin,$(1),$(2))
endef


$(eval $(call BuildPackage,ieee1905))
$(eval $(call BuildPackage,libieee1905))
$(eval $(call BuildPackage,map-plugin))
