#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=natalie-dect
PKG_VERSION:=12.26

PKG_SOURCE_VERSION:=19ee12a5451e1ce2a72ae5179fe5084e2b2832ba
ifeq ($(CONFIG_NATALIE_OPEN),y)
BRCM_KERNEL_PROFILE=$(shell echo $(CONFIG_BCM_KERNEL_PROFILE) | sed s/\"//g)
PKG_SOURCE:=$(PKG_NAME)-$(BRCM_KERNEL_PROFILE)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL:=http://iopsys.inteno.se/iopsys/consumer/
PKG_NAME:=natalie-dect-open
else
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL:=git@private.inteno.se:natalie-dect-12.26
PKG_SOURCE_PROTO:=git
endif

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk
include $(INCLUDE_DIR)/kernel.mk


BCM_KERNEL_VERSION=`cat $(BUILD_DIR)/bcmkernel/bcm963xx/kernel/linux-*/include/config/kernel.release`

export BUILD_DIR
export BCM_KERNEL_VERSION
export CONFIG_BCM_CHIP_ID := $(patsubst "%",%,$(CONFIG_BCM_CHIP_ID))
export CONFIG_BCM_KERNEL_PROFILE := $(patsubst "%",%,$(CONFIG_BCM_KERNEL_PROFILE))
export CONFIG_ARCH := $(patsubst "%",%,$(CONFIG_ARCH))
export TOOLS := $(CONFIG_BCM_TOOLCHAIN)/usr/bin/
export TOOLPREFIX := $(CONFIG_BCM_TOOLTUPLE)
export BRCM_MAX_JOBS := $(patsubst "%",%,$(CONFIG_BRCM_MAX_JOBS))
export MAKE_J
export BRCM_VERBOSE := $(if $(findstring c,$(OPENWRT_VERBOSE)),1,)
export PKG_BUILD_DIR
export BCM_SDK_PATH := $(BUILD_DIR)/bcmkernel/bcm963xx

define Package/natalie-dect
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Dect stack
  URL:=
  DEPENDS:=bcmkernel
endef

define Package/natalie-dect/config
	source "$(SOURCE)/Config.in"
endef

define Package/natalie-dect/description
	Kernel dect driver
endef

ifeq ($(CONFIG_NATALIE_OPEN),y)
define Build/Compile
endef
endif

define Package/natalie-dect/install
	$(INSTALL_DIR) $(1)/lib/modules/$(BCM_KERNEL_VERSION)/extra
	$(CP) $(PKG_BUILD_DIR)/dect.ko $(1)/lib/modules/$(BCM_KERNEL_VERSION)/extra/dect.ko
endef

$(eval $(call BuildPackage,natalie-dect))
