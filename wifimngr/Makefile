#
# Copyright (C) 2020 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifimngr
PKG_VERSION:=11.0.0

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=81bf292b5c273700db3ac3fbcb2d233365cbd2ee
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/wifimngr.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/wifimngr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WiFi status and configration utility
  DEPENDS:=+libwifi +libuci +libubox +ubus +libpthread +libnl-genl
endef

define Package/wifimngr/description
 This package can be used to configure and provide status about
 the WiFi modules through UBUS.
 It does this in an implementation agnostic manner through APIs
 exposed by the libwifi library.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
  rsync -r --exclude=.* ~/git/wifimngr/ $(PKG_BUILD_DIR)/
endef
endif

define Package/wifimngr/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifimngr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,wifimngr))
