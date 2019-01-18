#
# Copyright (C) 2013 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mqtt-ciotc
PKG_VERSION:=0.1

PKG_SOURCE_VERSION:=00da3fb1f1691d836037dc4d93e38d0835ba46a4
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/wifilife-testbed.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/mqtt-ciotc
	CATEGORY:=Utilities
	DEPENDS:=+libjwt +lib-paho-mqtt +libopenssl +libubox +ubus +libblobmsg-json
	TITLE:=mqtt google iot clinet
endef

define Package/mqtt-ciotc/description
	mqtt google iot client
endef

define Package/mqtt-ciotc/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mqtt_ciotc $(1)/sbin/
endef

$(eval $(call BuildPackage,mqtt-ciotc))
