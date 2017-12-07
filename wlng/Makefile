#
# Copyright (C) 2017 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=wlng
PKG_VERSION:=1.0.1

PKG_SOURCE_VERSION:=8af97fc73650853db433e08767a3470686162ddb
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/wlng

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_iopsys_ramips_ex400),y)
WLNG_TARGET:=-DIOPSYS_MEDIATEK
else ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_mips),y)
WLNG_TARGET:=-DIOPSYS_BROADCOM
KERNEL_DIR:=$(BUILD_DIR)/bcmkernel/bcm963xx
else ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
WLNG_TARGET:=-DIOPSYS_BROADCOM
else
$(info (UNEXPECTED CONFIG TARGET))
endif

export WLNG_TARGET
export KERNEL_DIR

define Package/wlng
	CATEGORY:=Utilities
	DEPENDS:=+libuci +libubox +ubus
	TITLE:=Wifilife NextGen (802.11 kvr based client steering)
endef

define Package/wlng/description
	wlng provides 802.11 kvr based AP assisted wifi client steering
	service through UBUS.
endef

define Package/wlng/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iwld $(1)/sbin/
endef

$(eval $(call BuildPackage,wlng))
