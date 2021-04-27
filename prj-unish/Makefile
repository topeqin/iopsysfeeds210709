#
# Copyright (C) 2021 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=prj-unish
PKG_VERSION:=0.7.0

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=595bd811428f4c1271cc8e2f61a9b6311f4672f0
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/prj-unish.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/prj-unish
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Project unish
  DEPENDS:=+libwifi +libuci +libubox +ubus +libpthread +libnl-genl
endef

define Package/prj-unish/description
 This package provides unish-paanch.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
  rsync -r --exclude=.* ~/git/prj-unish/ $(PKG_BUILD_DIR)/
endef
endif

define Build/InstallDev
	#$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	#$(CP) $(PKG_BUILD_DIR)/src/cmdu.h $(STAGING_DIR)/usr/include/
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/cmdu.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/lib*.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map2.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/map_module.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/lib*.so* $(1)/usr/lib/
endef


define Package/prj-unish/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/lib*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/i1905d $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/src/extensions/map/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,prj-unish))
