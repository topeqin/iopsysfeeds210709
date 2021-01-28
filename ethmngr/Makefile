#
# Copyright (C) 2020 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ethmngr
PKG_VERSION:=2.0.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=5a0ff3bc7c49dcb05129f423ef8e0c4929f6aa03
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/ethmngr.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/ethmngr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Ethernet status and configration utility
  DEPENDS:=+libethernet +libuci +libubox +ubus +libpthread +libnl-genl
endef

define Package/ethmngr/description
 This package can be used to configure and provide status about
 the ethernet interfaces and ports through UBUS.
 It uses APIs from the libethernet.so library.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

define Package/ethmngr/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_BIN) ./files/ethmngr.init $(1)/etc/init.d/ethmngr
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ethmngr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ethmngr))
