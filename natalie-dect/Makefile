#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=natalie-dect
PKG_VERSION:=12.26

PKG_SOURCE_VERSION:=35fed3a10124bd660b74704011256039ba9cf54d
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

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk
include $(INCLUDE_DIR)/kernel.mk


BCM_KERNEL_VERSION=`cat $(BUILD_DIR)/bcmkernel/bcm963xx/kernel/linux-*/include/config/kernel.release`

export BUILD_DIR
export BCM_KERNEL_VERSION

define Package/natalie-dect
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Dect stack
  URL:=
  DEPENDS:=bcmkernel
endef

define Package/natalie-dect/description
	Kernel dect driver
endef

ifeq ($(CONFIG_NATALIE_OPEN),y)
define Build/Compile
endef
endif

define Package/natalie-dect/install
	mkdir -p $(1)/lib/modules/$(BCM_KERNEL_VERSION)/extra/
ifeq ($(CONFIG_NATALIE_OPEN),y)
	$(CP) $(PKG_BUILD_DIR)/dect.ko $(1)/lib/modules/$(BCM_KERNEL_VERSION)/extra/dect.ko
else
	$(CP) $(PKG_BUILD_DIR)/NatalieFpCvm6362/Src/Projects/NatalieV3/FpCvm/Linux6362/dects.ko $(1)/lib/modules/$(BCM_KERNEL_VERSION)/extra/dect.ko
endif
endef

$(eval $(call BuildPackage,natalie-dect))
