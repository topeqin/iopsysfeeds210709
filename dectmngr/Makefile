#
# Copyright (C) 2021 IOPSYS Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=dectmngr
PKG_RELEASE:=3
PKG_VERSION:=3.0.11

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/dectmngr.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=045817eaf4644d5f7056fd1f3c928811c2fdfb89
PKG_MIRROR_HASH:=skip
endif

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

RSTRIP:=true
export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	CATEGORY:=Utilities
 	TITLE:=DECT Manager
 	DEPENDS:= +libubox +ubus
endef

define Package/$(PKG_NAME)/description
	DECT manager is a daemon that provides UBUS RPC objects and sends UBUS events for communication with the DECT chip.
endef

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
	rsync -av --exclude=.* ~/git/voip/dectmngr/* $(PKG_BUILD_DIR)/
endef
endif

MAKE_FLAGS += \
	CFLAGS+="-Wall"

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/app/dectmngr $(1)/usr/sbin/
	$(STRIP) $(1)/usr/sbin/dectmngr
	$(CP) ./files/etc/* $(1)/etc/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
