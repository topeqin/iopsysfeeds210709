#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libbbfdm
PKG_VERSION:=1.2-2020-05-04
PKG_FIXUP:=autoreconf
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/bbf.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=aed0e402f51b0272746fc86ff0918d189e714792
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/libbbf_api
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for libbbfdm API
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c
endef

define Package/libbbfdm
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for broadband-forum data model
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c +libtrace +libbbf_api +libopenssl +libmbedtls
endef

define Package/libbbfdm/config
	source "$(SOURCE)/Config_bbfdm.in"
endef

define Package/libbbf_api/description
 Library contains the API(UCI, UBUS, JSON, CLI and Browse) of libbbfdm
endef

define Package/libbbfdm/description
 Library contains the data model tree. It includes TR181, TR104, TR143, TR157 and TR064 data models
endef

USE_LOCAL=$(shell ls ./src/ 2>/dev/null >/dev/null && echo 1)
ifneq ($(USE_LOCAL),)
define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
endif

TARGET_CFLAGS += -DCUSTOM_PREFIX=\\\"$(CONFIG_LIBBBFDM_VENDOR_PREFIX)\\\"

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

ifeq ($(CONFIG_BBF_TR157),y)
CONFIGURE_ARGS += \
	--enable-tr157
endif

ifeq ($(CONFIG_BBF_TR064),y)
CONFIGURE_ARGS += \
	--enable-tr064
endif

ifeq ($(CONFIG_PACKAGE_libopenssl),y)
CONFIGURE_ARGS += \
	--enable-libopenssl
endif

ifeq ($(CONFIG_PACKAGE_libmbedtls),y)
CONFIGURE_ARGS += \
	--enable-libmbedtls
endif

define Package/libbbf_api/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbf_api.so* $(1)/lib/
endef

define Package/libbbfdm/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbfdm.so* $(1)/lib/
	$(INSTALL_DIR) $(1)/etc/bbfdm
	$(INSTALL_DIR) $(1)/etc/bbfdm/json
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/dmmap $(1)/etc/bbfdm
	$(INSTALL_DIR) $(1)/usr/share/bbfdm
	$(CP) $(PKG_BUILD_DIR)/scripts/functions $(1)/usr/share/bbfdm
	$(INSTALL_DIR) $(1)/usr/lib/bbfdm
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libbbfdm
	$(INSTALL_DIR) $(1)/usr/include/libbbf_api
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/libbbfdm/
	$(CP) $(PKG_BUILD_DIR)/dmtree/tr181/*.h $(1)/usr/include/libbbfdm/
	$(CP) $(PKG_BUILD_DIR)/dmtree/tr157/*.h $(1)/usr/include/libbbfdm/
	$(CP) $(PKG_BUILD_DIR)/libbbf_api/*.h $(1)/usr/include/libbbf_api/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbfdm.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbf_api.{a,so*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbbf_api))
$(eval $(call BuildPackage,libbbfdm))
