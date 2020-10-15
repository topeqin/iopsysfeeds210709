#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=map-1905
PKG_VERSION:=0.0.13

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=31e30c589cb2a522fb66261640ff1a5f8ff58ac4
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/map-1905.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/map-1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:= MultiAP Stack
  DEPENDS:= +ubox +ieee1905
endef

define Package/map-1905/description
 MultiAP plugin for ieee1905d based on Wifi alliance's MAP-r2 specification
endef

define Package/libmaputils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WFA MultiAP utility library
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE \
	-fstrict-aliasing \
	-Wall \
	-Wextra


ifeq ($(LOCAL_DEV),1)
define Build/Prepare
	$(CP) -rf ~/git/map-1905/* $(PKG_BUILD_DIR)/
endef
endif

define Package/map-1905/install
	$(INSTALL_DIR) $(1)/usr/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/ieee1905
	$(CP) $(PKG_BUILD_DIR)/libwifimap2.so $(1)/usr/lib/ieee1905/
endef

define Package/libmaputils/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libmaputils.so $(1)/usr/lib/libmaputils.so
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/map1905
	$(CP) $(PKG_BUILD_DIR)/include/*.h $(1)/usr/include/map1905/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libmaputils.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmaputils))
$(eval $(call BuildPackage,map-1905))
