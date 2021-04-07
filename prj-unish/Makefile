#
# Copyright (C) 2021 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=prj-unish
PKG_VERSION:=0.2.0

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=8df9d23366407f239946d64f539ad839f556a780
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

define Package/prj-unish/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/i1905d $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,prj-unish))
