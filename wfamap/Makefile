#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wfamap
PKG_VERSION:=1.0.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=97ced20d19a2c8373c12c488917439426ab372a1
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/wfamap.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/wfamap
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:= MultiAP Stack
  DEPENDS:= +ubox +lib1905al
endef

define Package/wfamap/description
 WiFi alliance multiAP stack
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE \
	-fstrict-aliasing \
	-Wall \
	-Wextra \
	-DFIX_BROKEN_TLVS \
	-DSPEED_UP_DISCOVERY

#define Build/Prepare
#	$(CP) -rf ./wfamap/* $(PKG_BUILD_DIR)/
#endef

define Package/wfamap/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwfamap.so $(1)/usr/lib/libwfamap.so
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/multiap
	$(CP) $(PKG_BUILD_DIR)/include/*.h $(1)/usr/include/multiap/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwfamap.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,wfamap))
