#
# Copyright (C) 2020 IOPSYS
#
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=swmodd
PKG_VERSION:=2.0.1

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=7971057300f315acda9ed1090e9a02fda7f5e5d5
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/swmodd.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/swmodd
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:= Software Modules Daemon
	DEPENDS:=+libuci +libubox +ubus +libuuid +libbbf_api +PACKAGE_liblxc:liblxc
endef

define Package/swmodd/description
	Software module daemon to manage software/deployment units using TR181 datamodel.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

ifeq ($(CONFIG_PACKAGE_liblxc),y)
MAKE_FLAGS += \
	SWMOD_LXC="yes"
endif

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
	$(CP) -rf ~/git/swmodd/* $(PKG_BUILD_DIR)/
endef
endif

define Package/swmodd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/lib/bbfdm
	$(INSTALL_DIR) $(1)/etc/swmod
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_CONF) ./files/map_du $(1)/etc/swmod/map_du
	$(INSTALL_BIN) ./files/swmodd.init $(1)/etc/init.d/swmodd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/swmodd $(1)/usr/sbin/swmodd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libswmodd.so $(1)/usr/lib/bbfdm/libswmodd.so
endef

$(eval $(call BuildPackage,swmodd))
