#
# Copyright (C) 2021 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ieee1905
PKG_VERSION:=0.3.1

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=a47110968d57fa1d0765900254b63c8ef983e741
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/prj-unish.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/ieee1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Project i1905
  DEPENDS:=+libwifi +libuci +libubox +ubus +libpthread +libnl-genl +libmidgen
endef

define Package/libi1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=i1905 library
  DEPENDS= +libubox +libuci +libubus +libeasy +libnl-genl +libwifi +libjson-c +libblobmsg-json +libmidgen
endef

define Package/libmidgen
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=i1905 addition library
  DEPENDS= +libpthread +libubox +libuci +libubus +libeasy +libnl-genl +libwifi +libjson-c +libblobmsg-json
endef

define Package/ieee1905/description
 This package provides i1905
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src


LIBS := \
	$(if $(CONFIG_PACKAGE_libi1905),libi1905) \
	$(if $(CONFIG_PACKAGE_libmidgen),libmidgen)

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
  rsync -r --exclude=.* ~/git/prj-unish/ $(PKG_BUILD_DIR)/
endef
endif

#define Build/InstallDev
#	#$(INSTALL_DIR) $(STAGING_DIR)/usr/include
#	#$(CP) $(PKG_BUILD_DIR)/src/cmdu.h $(STAGING_DIR)/usr/include/
#	$(INSTALL_DIR) $(1)/usr/include
#	$(INSTALL_DIR) $(1)/usr/lib
#	$(CP) $(PKG_BUILD_DIR)/src/cmdu.h $(1)/usr/include/
#	$(CP) $(PKG_BUILD_DIR)/src/lib*.so* $(1)/usr/lib/
#	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map2.h $(1)/usr/include/
#	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map_module.h $(1)/usr/include/
#	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/lib*.so* $(1)/usr/lib/
#endef


define Package/ieee1905/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/i1905
#	$(CP) $(PKG_BUILD_DIR)/src/lib*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/i1905d $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map.so $(1)/usr/lib/i1905/
endef

define Package/libi1905/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libi1905.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/libmaputil.so $(1)/usr/lib/libmaputil.so
endef

define Package/libmidgen/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libmidgen.so $(1)/usr/lib/
endef

define Build/InstallDev/libmidgen
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libmidgen.so $(1)/usr/lib/
endef


define Build/InstallDev/libi1905
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/i1905
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/src/cmdu.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/1905_tlvs.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/i1905_wsc.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/bufutil.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/timer_impl.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map2.h $(1)/usr/include/map22.h
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map.so $(1)/usr/lib/i1905/map.so
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map_module.h $(1)/usr/include/map_module22.h
	$(CP) $(PKG_BUILD_DIR)/src/libi1905.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/libmaputil.so $(1)/usr/lib/libmaputil.so
endef

define Build/InstallDev
	$(foreach lib,$(LIBS),$(call Build/InstallDev/$(lib),$(1),$(2));)
endef


$(eval $(call BuildPackage,ieee1905))
$(eval $(call BuildPackage,libi1905))
$(eval $(call BuildPackage,libmidgen))
