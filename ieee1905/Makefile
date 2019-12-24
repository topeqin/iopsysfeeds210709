#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ieee1905
PKG_VERSION:=1.1.3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=5662473a82582b00f35c7e8915734f033a2fe789
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/ieee1905.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ieee1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 handler
  DEPENDS:= +ubox +libpicoevent +libpcap +libopenssl +libuci +libjson-c
endef

define Package/ieee1905/description
 IEEE1905 stack with extended functionalities.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE \
	-DSEND_EMPTY_TLVS \
	-DFIX_BROKEN_TLVS \
	-DSPEED_UP_DISCOVERY \
	-DREGISTER_MULTIAP_FEATURE \
	-DDO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS
	#-DREGISTER_EXTENSION_BBF

#define Build/Prepare
#        $(CP) -rf ./ieee1905/* $(PKG_BUILD_DIR)/
#endef

define Package/ieee1905/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/etc/init.d/ieee1905 $(1)/etc/init.d/ieee1905
	$(INSTALL_DATA) ./files/etc/config/ieee1905 $(1)/etc/config/ieee1905
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ieee1905d $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libs/*.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,ieee1905))
