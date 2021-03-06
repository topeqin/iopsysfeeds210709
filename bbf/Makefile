#
# Copyright (C) 2021 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libbbfdm
PKG_VERSION:=4.3.6
PKG_FIXUP:=autoreconf
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/bbf.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=ece9282e8f1de4405c5e58a4c6a6263fd0cd7f81
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/libbbf_api
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=BBF
  TITLE:=Library for libbbfdm API
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c
endef

define Package/libbbfdm
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=BBF
  TITLE:=Library for broadband-forum data model
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c +libtrace +libbbf_api +libopenssl +libmbedtls +libcurl
endef

define Package/libbbfdm/config
	source "$(SOURCE)/Config_bbfdm.in"
endef

define Package/libbbf_api/description
 Library contains the API(UCI, UBUS, JSON, CLI and Browse) of libbbfdm
endef

define Package/libbbfdm/description
 Library contains the data model tree. It includes TR181, TR104 and TR143 data models
endef

USE_LOCAL=$(shell ls ./src/ 2>/dev/null >/dev/null && echo 1)
ifneq ($(USE_LOCAL),)
define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
endif

TARGET_CFLAGS += -DBBF_VENDOR_LIST=\\\"$(CONFIG_BBF_VENDOR_LIST)\\\"
TARGET_CFLAGS += -DBBF_VENDOR_PREFIX=\\\"$(CONFIG_BBF_VENDOR_PREFIX)\\\"

TARGET_CFLAGS += \
	-D_GNU_SOURCE -D_AADJ

ifeq ($(CONFIG_BBF_TR181),y)
CONFIGURE_ARGS += \
	--enable-tr181
endif

ifeq ($(CONFIG_BBF_TR104),y)
CONFIGURE_ARGS += \
	--enable-tr104
endif

ifeq ($(CONFIG_BBF_TR143),y)
CONFIGURE_ARGS += \
	--enable-tr143
endif

ifeq ($(CONFIG_PACKAGE_libopenssl),y)
CONFIGURE_ARGS += \
	--enable-libopenssl
endif

ifeq ($(CONFIG_PACKAGE_libmbedtls),y)
CONFIGURE_ARGS += \
	--enable-libmbedtls
endif

ifeq ($(CONFIG_BBF_VENDOR_EXTENSION),y)
CONFIGURE_ARGS += \
	--enable-vendor-extension

CONFIGURE_ARGS += \
	BBF_VENDOR_LIST="$(CONFIG_BBF_VENDOR_LIST)"

endif ##CONFIG_BBF_VENDOR_EXTENSION

define Package/libbbf_api/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbf_api.so* $(1)/lib/
endef

define Package/libbbfdm/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbfdm.so* $(1)/lib/
	$(INSTALL_DIR) $(1)/usr/share/bbfdm
	$(CP) $(PKG_BUILD_DIR)/scripts/* $(1)/usr/share/bbfdm
	$(INSTALL_DIR) $(1)/etc/bbfdm
	$(INSTALL_DIR) $(1)/etc/bbfdm/dmmap
	$(INSTALL_DIR) $(1)/etc/bbfdm/json
	$(INSTALL_DIR) $(1)/usr/lib/bbfdm
endef

define Package/libbbfdm/prerm
	#!/bin/sh
	rm -rf /etc/bbfdm/*
	exit 0
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libbbfdm
	$(INSTALL_DIR) $(1)/usr/include/libbbf_api
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/libbbfdm/
	$(CP) $(PKG_BUILD_DIR)/libbbf_api/*.h $(1)/usr/include/libbbf_api/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbfdm.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbf_api.{a,so*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbbf_api))
$(eval $(call BuildPackage,libbbfdm))
