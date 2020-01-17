#
# Copyright (C) 2019 IOPSYS Software Solutions AB
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wfadatad
PKG_VERSION:=1.0.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=d93bf451391af7b862ea053aece3fbfb85e90fbc
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/wfadatad.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/wfadatad
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Wifi data element agent
  DEPENDS:=+libwifi +libuci +libubox +ubus +libpthread +libnl-genl
endef

define Package/wfadatad/description
 Wifi data element agent collects all WiFi related data
 and stores it which can be used by high level data collectors.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_PATH:=src

#define Build/Prepare
#        $(CP) -rf ./wfadatad/src/* $(PKG_BUILD_DIR)/
#endef

define Package/wfadatad/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/wfadatad.init $(1)/etc/init.d/wfadatad
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wfadatad $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,wfadatad))
