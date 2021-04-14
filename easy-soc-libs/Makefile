#
# Copyright (C) 2020 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=easy-soc-libs
PKG_VERSION:=6.2.0
PKG_RELEASE:=1

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=2f82f0555abd8e53653c8455f1b8aab00d50c208
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/easy-soc-libs.git
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/easy-soc-libs
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=IOPSYS Easy SoC libraries
  SUBMENU:=IOPSYS Easy SoC libraries
  DEPENDS:=+libopenssl
  MENU:=1
endef

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
  TARGET_PLATFORM=BROADCOM
  CHIP_ID=$(patsubst "%",%,$(CONFIG_BCM_CHIP_ID))
  TARGET_CFLAGS +=-DIOPSYS_BROADCOM -DCHIP_$(CHIP_ID) -DCONFIG_BCM9$(CHIP_ID) \
	-I$(STAGING_DIR)/usr/include/bcm963xx/bcmdrivers/opensource/include/bcm963xx \
	-I$(STAGING_DIR)/usr/include/bcm963xx/userspace/public/include
else ifeq ($(CONFIG_TARGET_iopsys_ramips),y)
  TARGET_PLATFORM=MEDIATEK
  TARGET_CFLAGS +=-DIOPSYS_MEDIATEK
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
  TARGET_PLATFORM=MARVELL
  TARGET_CFLAGS +=-DIOPSYS_MARVELL
else ifeq ($(CONFIG_TARGET_intel_mips),y)
  TARGET_PLATFORM=INTEL
  TARGET_CFLAGS +=-DIOPSYS_INTEL
else ifeq ($(CONFIG_TARGET_iopsys_x86),y)
  TARGET_PLATFORM=TEST
  TARGET_CFLAGS +=-DIOPSYS_TEST
else ifeq ($(CONFIG_TARGET_iopsys_armvirt),y)
  TARGET_PLATFORM=TEST
  TARGET_CFLAGS +=-DIOPSYS_TEST
else
  $(info Unexpected CONFIG_TARGET, use default MAC80211)
  TARGET_PLATFORM=MAC80211
  TARGET_CFLAGS +=-DIOPSYS_MAC80211
endif

export TARGET_PLATFORM

subdirs := \
	$(if $(CONFIG_PACKAGE_libeasy),libeasy) \
	$(if $(CONFIG_PACKAGE_libwifi),libwifi) \
	$(if $(CONFIG_PACKAGE_libdsl),libdsl) \
	$(if $(CONFIG_PACKAGE_libethernet),libethernet) \
	$(if $(CONFIG_PACKAGE_libqos),libqos)

EASY_SOC_LIBS := \
	libeasy \
	libwifi \
	libdsl \
	libethernet \
	libqos

ifeq ($(CONFIG_LIBWIFI_USE_CTRL_IFACE),y)
  TARGET_CFLAGS +=-DLIBWIFI_USE_CTRL_IFACE
endif

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

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
	rsync -r --exclude=.* ~/git/easy-soc-libs/ $(PKG_BUILD_DIR)/
endef
endif

include easy.mk
include wifi.mk
include dsl.mk
include ethernet.mk
include qos.mk

ifneq ($(wildcard $(PKG_BUILD_DIR)/.config_*),\
	$(PKG_BUILD_DIR)/.config_$(patsubst "%",%,$(CONFIG_TARGET_PROFILE)))
define Build/Compile/rebuild
	$(FIND) $(PKG_BUILD_DIR) -name \*.o -or -name \*.so\* | $(XARGS) rm -f;
	$(if $(wildcard $(PKG_BUILD_DIR)/config_*), \
		rm -f $(PKG_BUILD_DIR)/.config_*)
endef
endif

STAMP_CONFIGURED:=$(strip $(STAMP_CONFIGURED))_$(shell echo $(TARGET_CFLAGS) | mkhash md5)

define Build/Compile
	$(Build/Compile/rebuild)
	touch $(PKG_BUILD_DIR)/.config_$(CONFIG_TARGET_PROFILE)
	$(call Build/Compile/Default)
	$(foreach dir,$(subdirs),$(call Build/Compile/$(dir)))
endef

define Build/InstallDev
	$(foreach dir,$(subdirs),$(call Build/InstallDev/$(dir),$(1),$(2));)
endef

define Package/easy-soc-libs/install
	:
endef

$(eval $(foreach e,$(EASY_SOC_LIBS),$(call BuildPackage,$(e))))
