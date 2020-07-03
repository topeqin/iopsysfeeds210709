#
# Copyright (C) 2020 IOPSYS Software Solutions AB
#

include $(TOPDIR)/rules.mk

PKG_NAME:=map-controller
PKG_VERSION:=1.0.1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=3a55c1f41f0e2c233c28834dea0e881cd2cd0c22

PKG_LICENSE:=PROPRIETARY IOPSYS
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/map-controller.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz

include $(INCLUDE_DIR)/package.mk

define Package/map-controller
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=WiFi Multi-AP Controller (EasyMesh R2)
  DEPENDS:=+libuci +libubox +ubus
endef

define Package/map-controller/description
 This package provides WiFi MultiAP Controller as per the EasyMesh-R2 specs.
endef

define Package/map-controller/config
	#source "$(SOURCE)/Config.in"
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src

define Package/map-controller/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mapcontroller $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,map-controller))
