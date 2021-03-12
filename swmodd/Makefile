#
# Copyright (C) 2020 IOPSYS
#
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=swmodd
PKG_VERSION:=1.1.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c8cc4a3b332ea931dbf2fe7e6b94bebf5c4bcc33
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/swmodd.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/swmodd
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=SWMOD - software modules ubus backend
	DEPENDS:=+libuci +libubox +ubus +libuuid +PACKAGE_liblxc:liblxc
endef

define Package/swmodd/description
	Ubus based backend for software modules which can be used by other applications running on top of it.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

ifeq ($(CONFIG_PACKAGE_liblxc),y)
MAKE_FLAGS += \
	SWMOD_LXC="yes"
endif

define Package/swmodd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/swmodd.init $(1)/etc/init.d/swmodd
	$(INSTALL_DIR) $(1)/etc/swmod
	$(INSTALL_CONF) ./files/map_du $(1)/etc/swmod/map_du
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/swmodd $(1)/usr/sbin/swmodd
endef

$(eval $(call BuildPackage,swmodd))
