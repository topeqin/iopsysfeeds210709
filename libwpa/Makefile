#
# Copyright (C) 2020 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libwpa
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://w1.fi/hostap.git
PKG_SOURCE_VERSION:=5a8b366233f5585e68a4ffbb604fbb4a848eb325

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_libwpa_client

ifdef CONFIG_USE_GLIBC
  TARGET_LDFLAGS += -lrt
  TARGET_LDFLAGS_C += -lrt
endif

define Package/libwpa_client/Default
  PROVIDES:=libwpa_client
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WirelessAPD
  TITLE:=WPA Client
  URL:=http://hostap.epitest.fi/wpa_supplicant/
endef

define Package/libwpa_client
$(call Package/libwpa_client/Default,$(1))
  TITLE:= (SO library)
  VARIANT:=libwpa_client
endef

define Package/libwpa_client/description
 This package contains wpa_ctrl client library
endef

define Build/Configure/rebuild
	$(FIND) $(PKG_BUILD_DIR) -name \*.o -or -name \*.a -or -name \*.so | $(XARGS) rm -f
	rm -f $(PKG_BUILD_DIR)/wpa_supplicant/libwpa_client.so
	rm -f $(PKG_BUILD_DIR)/.config_*
endef

define Build/Configure
	$(Build/Configure/rebuild)
	$(if $(wildcard ./files/libwpa_client.config), \
		$(CP) ./files/libwpa_client.config $(PKG_BUILD_DIR)/wpa_supplicant/.config
	)
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

MAKE_PATH:=wpa_supplicant

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libwpa
	$(CP) $(PKG_BUILD_DIR)/src/common/wpa_ctrl.h $(1)/usr/include/libwpa/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/wpa_supplicant/*.so* $(1)/usr/lib/
endef

define Package/libwpa_client/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/wpa_supplicant/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwpa_client))
