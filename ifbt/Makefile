#
# Copyright (C) 2018 iopsys Software Solutions AB
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ifbt
PKG_VERSION:=0.1

PKG_SOURCE_VERSION:=104d3e61029cd82b1399c16b4791540c4c318cb9
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/ifbt.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_mips),y)
TARGET_PLATFORM:=-DIOPSYS_BROADCOM
else ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
TARGET_PLATFORM:=-DIOPSYS_BROADCOM
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
TARGET_PLATFORM:=-DIOPSYS_MARVELL
else ifeq ($(CONFIG_TARGET_intel_mips),y)
TARGET_PLATFORM:=-DIOPSYS_INTEL
else ifeq ($(CONFIG_TARGET_iopsys_ramips),y)
TARGET_PLATFORM:=-DIOPSYS_MEDIATEK
else
$(info (UNEXPECTED CONFIG TARGET))
endif

export TARGET_PLATFORM

define Package/ifbt
	CATEGORY:=Utilities
	DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c  +libwifi +libjson-c
	TITLE:=Fast BSS Transition
endef

define Package/ifbt/description
	ifbt is Iopsys application for fast BSS transition
endef

define Package/ifbt/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ifbt $(1)/sbin/
endef

$(eval $(call BuildPackage,ifbt))
