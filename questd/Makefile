#
# Copyright (C) 2013 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=questd
PKG_VERSION:=3.1.38

PKG_SOURCE_VERSION:=8d89f663e30b93cd314df708bf6abbef342d52ee
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/questd

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_mips),y)
QUESTD_TARGET:=-DIOPSYS_BROADCOM
KERNEL_DIR:=$(BUILD_DIR)/bcmkernel/bcm963xx
else ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
QUESTD_TARGET:=-DIOPSYS_BROADCOM
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
QUESTD_TARGET:=-DIOPSYS_MARVELL
else ifeq ($(CONFIG_TARGET_lantiq_xrx500),y)
QUESTD_TARGET:=-DIOPSYS_LANTIQ
else ifeq ($(CONFIG_TARGET_iopsys_ramips_ex400),y)
QUESTD_TARGET:=-DIOPSYS_MEDIATEK
QUESTD_CFLAGS:=\
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl-tiny
else
$(info (UNEXPECTED CONFIG TARGET))
endif
QUESTD_CFLAGS:=$(QUESTD_CFLAGS) $(QUESTD_TARGET)

export QUESTD_TARGET
export KERNEL_DIR
export QUESTD_CFLAGS

define Package/questd
	CATEGORY:=Utilities
	DEPENDS:=+libuci +libubox +ubus +libpthread +(TARGET_iopsys_ramips_ex400):swconfig +(TARGET_iopsys_ramips_ex400):libnl-tiny
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wificontrol $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/graphd $(1)/sbin/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/netcheck $(1)/usr/bin/
endef

$(eval $(call BuildPackage,questd))
