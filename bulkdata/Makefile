#
# Copyright (C) 2020 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bulkdata
PKG_VERSION:=1.0.1

PKG_SOURCE_VERSION:=e4f39d1bf4678fc05b9d02e81b194c70719909e4
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/bulkdata.git

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
  TITLE:=BBF BulkData Collection
  DEPENDS:=+libubus +libuci +libubox +libjson-c +libcurl +curl +libblobmsg-json +libbbfdm +libbbf_api
endef

define Package/$(PKG_NAME)/description
	BBF BulkData Collection
endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bulkdatad $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/bbfdm
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/*.so $(1)/usr/lib/bbfdm
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
