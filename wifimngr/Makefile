#
# Copyright (C) 2015 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=wifimngr
PKG_VERSION:=2016-03-29

PKG_SOURCE_VERSION:=9dae4438b781b0abb7ca9e16c37c0344b16ccf2a
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/wifimngr

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

LDFLAGS+= \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib \
	-Wl,-rpath-link=$(STAGING_DIR)/lib

define Package/wifimngr
	CATEGORY:=Network
	DEPENDS:=+libpthread +libstdcpp +librt +libjson +alljoyn +alljoyn-about +ubus +libuci
	TITLE:=WiFi Manager
endef

define Package/wifimngr/description
	wifimngr manages wireless driver
endef

define Package/wifimngr/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifimngr $(1)/sbin/
endef

define Package/wifimngr/postinst
	/etc/init.d/alljoyn restart
	pidof alljoyn-daemon >/dev/null && wifimngr &
endef

$(eval $(call BuildPackage,wifimngr))
