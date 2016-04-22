#
# Copyright (C) 2013 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=questd
PKG_VERSION:=3.1.0

PKG_SOURCE_VERSION:=d7e9195cfda57cfe361548a3cff35273c65626f3
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/questd

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

LDFLAGS+= \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib \
	-Wl,-rpath-link=$(STAGING_DIR)/lib

ifeq ($(CONFIG_PACKAGE_bcmkernel),y)
BCMKERNEL_DIR:=$(BUILD_DIR)/bcmkernel/bcm963xx
else
BCMKERNEL_DIR:=$(BUILD_DIR)/bcmopen-consumer/bcm963xx
endif
export BCMKERNEL_DIR

define Package/questd
	CATEGORY:=Utilities
	DEPENDS:=+libuci +libubox +ubus +libpthread
	TITLE:=router info daemon
endef

define Package/questd/description
	questd collects system and network information and presents
	this information via ubus
endef

define Package/questd/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/questd $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ueventd $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uscriptd $(1)/sbin/
endef

$(eval $(call BuildPackage,questd))
