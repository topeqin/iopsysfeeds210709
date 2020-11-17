#
# Copyright (C) 2020 IOPSYS
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lib-paho-mqtt
PKG_VERSION:=0.1

PKG_SOURCE_VERSION:=9f715d0862a8e16099b5837c4e53a1bf6a6a0675
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/eclipse/paho.mqtt.c.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=edl-v10
PKG_LICENSE_FILES:=LICENSE


include $(INCLUDE_DIR)/package.mk

define Package/lib-paho-mqtt
	CATEGORY:=Libraries
	DEPENDS:=+libopenssl
	TITLE:=package for mqtt stuff
endef


define Package/lib-paho-mqtt/description
	a library
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/*.h $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/output/*.so* $(1)/usr/lib/
endef

define	Package/lib-paho-mqtt/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/output/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,lib-paho-mqtt))
