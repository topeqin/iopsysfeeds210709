#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ieee1905
PKG_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0f32eabc1a79c6c41dd9e6ae7c231ae73071dc39
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/ieee1905.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ieee1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 parser
  DEPENDS:=+meshcomms +libubox +libubus +libblobmsg-json
endef

define Package/ieee1905/description
 Listens to ieee1905 messages, parse and expose them over ubus.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

#define Build/Prepare
#        $(CP) -rf ./ieee1905/* $(PKG_BUILD_DIR)/
#endef

define Package/ieee1905/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ieee1905 $(1)/etc/init.d/ieee1905
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ieee1905 $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ieee1905))
