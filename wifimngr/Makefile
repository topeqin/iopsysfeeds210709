#
# Copyright (C) 2018 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifimngr
PKG_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=a9b2632692e3a366947cf76a64cafa191e2461a3
PKG_SOURCE_URL:=http://public.inteno.se:/wifimngr
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@inteno.se>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

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

#MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	FPIC="$(FPIC)"

#define Build/Compile
#	+$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
#endef

define Package/wifimngr/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifimngr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,wifimngr))
