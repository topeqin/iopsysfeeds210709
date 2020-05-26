#
# Copyright (C) 2020 IOPSYS
#
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=swmodd
PKG_VERSION:=1.0.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=3bfc97cd6f8e22f561601c47b79203b17fdb0fbe
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/swmodd.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/swmodd
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=SWMOD - software modules ubus backend
	DEPENDS:=+libuci +libubox +ubus +libuuid
endef

define Package/swmodd/description
	Ubus based backend for software modules which can be used by other applications running on top of it.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

define Package/swmodd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/swmodd.init $(1)/etc/init.d/swmodd
	$(INSTALL_DIR) $(1)/etc/swmod
	$(INSTALL_CONF) ./files/map_du $(1)/etc/swmod/map_du
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/swmodd $(1)/usr/sbin/swmodd
endef

$(eval $(call BuildPackage,swmodd))
