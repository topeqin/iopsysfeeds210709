#
# Copyright (C) 2019 IOPSYS
#
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=opkgd
PKG_VERSION:=1.0.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c5ead73a9c667ceaaba32826d27be53fdddaad24
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/opkgd.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/opkgd
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=OPKG ubus backend
	DEPENDS:=+libuci +libubox +ubus +libuuid
endef

define Package/opkgd/description
	Ubus based backend for OPKG which can be used by other applications running on top of it.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

define Package/opkgd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/opkgd.init $(1)/etc/init.d/opkgd
	$(INSTALL_DIR) $(1)/etc/opkg
	$(INSTALL_CONF) ./files/map_du $(1)/etc/opkg/map_du
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/opkgd $(1)/usr/sbin/opkgd
endef

$(eval $(call BuildPackage,opkgd))
