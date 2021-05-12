#
# Copyright (C) 2020 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stunc
PKG_VERSION:=1.0.2

PKG_SOURCE_VERSION:=d578df0c8e4e7d1b642a5cf037ce468379270534
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/stunc.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=TRx69
  TITLE:=BBF STUN Client
  DEPENDS:=+libubus +libuci +libubox +libjson-c +libopenssl +libblobmsg-json +libbbf_api
endef

define Package/$(PKG_NAME)/description
	BBF STUN Client
endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/lib/bbfdm
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libstunc.so $(1)/usr/lib/bbfdm/libstunc.so
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/stunc $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/stunc $(1)/etc/init.d/stunc
	$(INSTALL_DATA) ./files/etc/config/stunc $(1)/etc/config/stunc
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
