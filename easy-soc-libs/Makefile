#
# Copyright (C) 2018 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=easy-soc-libs
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=7fdc60c76a432ab4059bf35f22be58068b8f1501
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/easy-soc-libs.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@inteno.se>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/easy-soc-libs
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=IOPSYS easy SoC libraries
  SUBMENU:=IOPSYS easy SoC libraries
  DEPENDS:=+libopenssl
  MENU:=1
endef

define Package/libwifi/config
  source "$(SOURCE)/Config.in"
endef

define Package/libwifi
  $(call Package/easy-soc-libs)
  TITLE:= WiFi library (libwifi)
endef

define Package/libdsl
  $(call Package/easy-soc-libs)
  TITLE:= XDSL library (libdsl)
endef

define Package/libethernet
  $(call Package/easy-soc-libs)
  TITLE:= Ethernet library (libethernet)
  DEPENDS:=+TARGET_iopsys_ramips:swconfig
endef

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_mips),y)
  TARGET_PLATFORM=BROADCOM
  TARGET_CFLAGS +=-DIOPSYS_BROADCOM -DCONFIG_BCM963138
  KERNEL_DIR:=$(BUILD_DIR)/bcmkernel/bcm963xx
else ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
  TARGET_PLATFORM=BROADCOM
  TARGET_CFLAGS +=-DIOPSYS_BROADCOM -DCONFIG_BCM963138
else ifeq ($(CONFIG_TARGET_iopsys_ramips),y)
  TARGET_PLATFORM=MEDIATEK
  TARGET_CFLAGS +=-DIOPSYS_MEDIATEK
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
  TARGET_PLATFORM=MARVELL
  TARGET_CFLAGS +=-DIOPSYS_MARVELL
else ifeq ($(CONFIG_TARGET_lantiq_xrx500),y)
  TARGET_PLATFORM=LANTIQ
  TARGET_CFLAGS +=-DIOPSYS_LANTIQ
else
  $(info (UNEXPECTED CONFIG TARGET))
endif

ifdef CONFIG_IOP_LLA_LIBS_DEBUG
  TARGET_CFLAGS += -DIOP_LLA_LIBS_DEBUG
endif

subdirs := \
	$(if $(CONFIG_PACKAGE_libwifi),libwifi) \
	$(if $(CONFIG_PACKAGE_libdsl),libdsl) \
	$(if $(CONFIG_PACKAGE_libethernet),libethernet)

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	FPIC="$(FPIC)" \
	PLATFORM="$(TARGET_PLATFORM)" \
	subdirs="$(subdirs)"

define Build/InstallDev/libwifi
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifi/wifi.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libwifi/libwifi.so* $(1)/usr/lib/
endef

define Build/InstallDev/libdsl
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libdsl/xdsl.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libdsl/libdsl.so* $(1)/usr/lib/
endef

define Build/InstallDev/libethernet
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libethernet/ethernet.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libethernet/libethernet.so $(1)/usr/lib/
endef


define Build/InstallDev
	$(foreach dir,$(subdirs),$(call Build/InstallDev/$(dir),$(1),$(2));)
endef

define Package/libwifi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifi/libwifi.so* $(1)/usr/lib/
endef

define Package/libethernet/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libethernet/libethernet.so* $(1)/usr/lib/
endef

define Package/libdsl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libdsl/libdsl.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwifi))
$(eval $(call BuildPackage,libdsl))
$(eval $(call BuildPackage,libethernet))
