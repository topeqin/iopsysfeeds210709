#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifimngr
PKG_VERSION:=2.4.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c4063e9c5581fed6e75037d0b13698b7cb2d6c2a
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/wifimngr.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
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
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wifimngr.init $(1)/etc/init.d/wifimngr
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifimngr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,wifimngr))
