#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ieee1905
PKG_VERSION:=2.0.27

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=ffa102fa6c66f0996c7eaafc0a49abcd3488ad06
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/ieee1905.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ieee1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 daemon
  DEPENDS:= +libuci +libjson-c +libieee1905 +ubox +libpcap +libopenssl +libwifi +libeasy
endef

define Package/ieee1905/config
	source "$(SOURCE)/Config.in"
endef

define Package/ieee1905/description
 IEEE1905 stack with extended functionalities.
endef

define Package/libieee1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 cmdu tlv utility library
endef

define Package/lib1905hle
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 hle stack library
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE \
	-fstrict-aliasing \
	-Wall \
	-Wextra

ifeq ($(CONFIG_IEEE1905_SPEED_UP_DISCOVERY),y)
TARGET_CFLAGS += -DSPEED_UP_DISCOVERY
endif
ifeq ($(CONFIG_IEEE1905_DO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS),y)
TARGET_CFLAGS += -DDO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS
endif
ifeq ($(CONFIG_IEEE1905_ALME_OVER_TCP),y)
TARGET_CFLAGS += -DALME_OVER_TCP
endif
ifeq ($(CONFIG_IEEE1905_ALME_OVER_UBUS),y)
TARGET_CFLAGS += -DALME_OVER_UBUS
endif
ifeq ($(CONFIG_IEEE1905_MAP_COMPLETE_NETWORK),y)
TARGET_CFLAGS += -DIEEE1905_MAP_COMPLETE_NETWORK
endif

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
	$(CP) -rf ~/git/ieee1905/* $(PKG_BUILD_DIR)/
endef
endif

define Package/ieee1905/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/ieee1905
	$(INSTALL_DIR) $(1)/usr/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/etc/init.d/ieee1905 $(1)/etc/init.d/ieee1905
	$(INSTALL_DATA) ./files/etc/config/ieee1905 $(1)/etc/config/ieee1905
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ieee1905d $(1)/usr/sbin/
endef

define Package/lib1905hle/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/lib1905hle.so $(1)/usr/lib/lib1905hle.so
endef

define Package/libieee1905/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libieee1905.so $(1)/usr/lib/libieee1905.so
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/ieee1905
	$(INSTALL_DIR) $(1)/usr/include/ieee1905
	$(INSTALL_DIR) $(1)/usr/include/lib1905hle
	$(CP) $(PKG_BUILD_DIR)/include/*.h $(1)/usr/include/ieee1905/
	$(CP) $(PKG_BUILD_DIR)/libieee1905/include/*.h $(1)/usr/include/ieee1905/
	$(CP) $(PKG_BUILD_DIR)/lib1905hle/include/*.h $(1)/usr/include/lib1905hle/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libieee1905.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,libieee1905))
$(eval $(call BuildPackage,lib1905hle))
$(eval $(call BuildPackage,ieee1905))
