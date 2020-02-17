#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wfamap
PKG_VERSION:=1.0.4

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=1c6b48cb5a0081087de4c7db74b24685210d77f2
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
	-Wextra

ifeq ($(CONFIG_IEEE1905_SEND_EMPTY_TLVS),y)
TARGET_CFLAGS += -DSEND_EMPTY_TLVS
endif
ifeq ($(CONFIG_IEEE1905_FIX_BROKEN_TLVS),y)
TARGET_CFLAGS += -DFIX_BROKEN_TLVS
endif
ifeq ($(CONFIG_IEEE1905_SPEED_UP_DISCOVERY),y)
TARGET_CFLAGS += -DSPEED_UP_DISCOVERY
endif
ifeq ($(CONFIG_IEEE1905_DO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS),y)
TARGET_CFLAGS += -DDO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS
endif



#define Build/Prepare
#	$(CP) -rf ./wfamap/* $(PKG_BUILD_DIR)/
#endef

define Package/wfamap/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifimap-2.so $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/wifimap
	$(CP) $(PKG_BUILD_DIR)/include/*.h $(1)/usr/include/wifimap/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifimap-2.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,wfamap))
