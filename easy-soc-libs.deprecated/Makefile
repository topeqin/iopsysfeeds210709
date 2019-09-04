#
# Copyright (C) 2019 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=easy-soc-libs.deprecated
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=85a9a7970469212ae2a8446582f04a8a5da7146f
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/easy-soc-libs.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/easy-soc-libs.deprecated
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=IOPSYS easy SoC libraries (deprecated)
  SUBMENU:=IOPSYS easy SoC libraries (deprecated)
  DEPENDS:=+libopenssl
  MENU:=1
endef

define Package/libwifix/config
  source "$(SOURCE)/Config.in"
endef

define Package/libwifix
  $(call Package/easy-soc-libs.deprecated)
  TITLE:= WiFi library for wifix (deprecated)
  DEPENDS+=+libnl +libnl-route
endef

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_mips),y)
  TARGET_PLATFORM=BROADCOM
  TARGET_CFLAGS +=-DIOPSYS_BROADCOM -DCONFIG_BCM963138 \
	-I$(STAGING_DIR)/usr/include/bcm963xx/bcmdrivers/opensource/include/bcm963xx
  KERNEL_DIR:=$(BUILD_DIR)/bcmkernel/bcm963xx
else ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
  TARGET_PLATFORM=BROADCOM
  TARGET_CFLAGS +=-DIOPSYS_BROADCOM -DCONFIG_BCM963138 \
	-I$(STAGING_DIR)/usr/include/bcm963xx/bcmdrivers/opensource/include/bcm963xx
else ifeq ($(CONFIG_TARGET_iopsys_ramips),y)
  TARGET_PLATFORM=MEDIATEK
  TARGET_CFLAGS +=-DIOPSYS_MEDIATEK
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
  TARGET_PLATFORM=MARVELL
  TARGET_CFLAGS +=-DIOPSYS_MARVELL
else ifeq ($(CONFIG_TARGET_intel_mips),y)
  TARGET_PLATFORM=INTEL
  TARGET_CFLAGS +=-DIOPSYS_INTEL
else
  $(info Unexpected CONFIG_TARGET)
endif

export TARGET_PLATFORM

ifdef CONFIG_LIBWIFIX_DEBUG
  TARGET_CFLAGS += -DIOP_LLA_LIBS_DEBUG
endif

subdirs := \
	$(if $(CONFIG_PACKAGE_libwifix),libwifix)

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/openssl \
	-I$(STAGING_DIR)/usr/include/libnl3

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -Wall -I./" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	FPIC="$(FPIC)" \
	PLATFORM="$(TARGET_PLATFORM)" \
	subdirs="$(subdirs)"

define Build/InstallDev/libwifix
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifix/wifi.h $(1)/usr/include/wifix.h
	$(CP) $(PKG_BUILD_DIR)/libwifix/libwifi*.so* $(1)/usr/lib/
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Build/InstallDev
	$(foreach dir,$(subdirs),$(call Build/InstallDev/$(dir),$(1),$(2));)
endef

define Package/libwifix/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifix/libwifi*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwifix))
