#
# Copyright (C) 2019 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ieee1905
PKG_VERSION:=2.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=5c8400b9021f3b191b05733a55e01f3aa113beee
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/ieee1905.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ieee1905
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 daemon
  DEPENDS:= +libuci +libjson-c +lib1905al +lib1905ubus
endef

define Package/ieee1905/description
 IEEE1905 stack with extended functionalities.
endef

define Package/lib1905al
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 stack library
  DEPENDS:= +libpcap +libopenssl 
endef

define Package/lib1905ubus
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IEEE1905 ubus library
  DEPENDS:= +ubox +libpicoevent +libjson-c
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
	-Wextra \
	-DSEND_EMPTY_TLVS \
	-DFIX_BROKEN_TLVS \
	-DSPEED_UP_DISCOVERY \
	-DDO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS
	#-DREGISTER_MULTIAP_FEATURE \
	#-DREGISTER_EXTENSION_BBF


#define Build/Prepare
#        $(CP) -rf ./ieee1905/* $(PKG_BUILD_DIR)/
#endef

define Package/ieee1905/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/etc/init.d/ieee1905 $(1)/etc/init.d/ieee1905
	$(INSTALL_DATA) ./files/etc/config/ieee1905 $(1)/etc/config/ieee1905
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ieee1905d $(1)/usr/sbin/
endef

define Package/lib1905hle/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/lib1905hle.so $(1)/usr/lib/lib1905hle.so
endef

define Package/lib1905al/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/lib1905al.so $(1)/usr/lib/lib1905al.so
endef

define Package/lib1905ubus/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/lib1905ubus.so $(1)/usr/lib/lib1905ubus.so
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/lib1905al
	$(INSTALL_DIR) $(1)/usr/include/lib1905hle
	$(INSTALL_DIR) $(1)/usr/include/lib1905ubus
	$(CP) $(PKG_BUILD_DIR)/lib1905al/include/*.h $(1)/usr/include/lib1905al/
	$(CP) $(PKG_BUILD_DIR)/lib1905ubus/include/*.h $(1)/usr/include/lib1905ubus/
	$(CP) $(PKG_BUILD_DIR)/lib1905hle/include/*.h $(1)/usr/include/lib1905hle/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/lib1905al.so $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/lib1905ubus.so $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/lib1905hle.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,lib1905al))
$(eval $(call BuildPackage,lib1905ubus))
$(eval $(call BuildPackage,lib1905hle))
$(eval $(call BuildPackage,ieee1905))
