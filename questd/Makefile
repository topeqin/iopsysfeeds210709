#
# Copyright (C) 2013 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=questd
PKG_VERSION:=3.1.16

PKG_SOURCE_VERSION:=bace8d50d6e94cfbe063aff69e643fb3bc80d748
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/questd

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_mips),y)
QUESTD_CLFAGS:=-DIOPSYS_BROADCOM
KERNEL_DIR:=$(BUILD_DIR)/bcmkernel/bcm963xx
else ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
QUESTD_CLFAGS:=-DIOPSYS_BROADCOM
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
QUESTD_CLFAGS:=-DIOPSYS_MARVELL
else ifeq ($(CONFIG_TARGET_lantiq_xrx500),y)
QUESTD_CLFAGS:=-DIOPSYS_LANTIQ
else
$(info (UNEXPECTED CONFIG TARGET))
endif

export KERNEL_DIR
export QUESTD_CLFAGS

define Package/questd
	CATEGORY:=Utilities
	DEPENDS:=+libuci +libubox +ubus +libpthread
	TITLE:=router info daemon
endef

define Package/questd/description
	questd collects system and network information and presents
	this information via ubus
endef

define Package/questd/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/questd $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uscriptd $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wificontrol $(1)/sbin/
endef

$(eval $(call BuildPackage,questd))
