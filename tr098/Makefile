#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtr098
PKG_VERSION:=1.0-2019-09-25
PKG_FIXUP:=autoreconf
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/tr-098
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c2de93e288907da239652bd137f2ddee389b5042
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libtr098
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for broadband-forum data model
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c +libtrace
endef

define Package/libtr098/config
	source "$(SOURCE)/Config.in"
endef

define Package/libtr098/description
 Test description will update later.
endef

USE_LOCAL=$(shell ls ./src/ 2>/dev/null >/dev/null && echo 1)
ifneq ($(USE_LOCAL),)
define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
endif

TARGET_CFLAGS += -DCUSTOM_PREFIX=\\\"$(CONFIG_LIBTR098_VENDOR_PREFIX)\\\"

TARGET_CFLAGS += \
	-D_GNU_SOURCE -D_AADJ

ifeq ($(CONFIG_UPNP_TR064),y)
CONFIGURE_ARGS += \
	--enable-tr064
endif

define Package/libtr098/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libtr098.so* $(1)/lib/
	$(INSTALL_DIR) $(1)/etc/tr098
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/dmmap $(1)/etc/tr098
	$(INSTALL_DIR) $(1)/usr/share/tr098
	$(CP) $(PKG_BUILD_DIR)/scripts/functions $(1)/usr/share/tr098
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/libtr098
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/libtr098/
	$(CP) $(PKG_BUILD_DIR)/tr098/*.h $(1)/usr/include/libtr098/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libtr098.{a,so*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtr098))
