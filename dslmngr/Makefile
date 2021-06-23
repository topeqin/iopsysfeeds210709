#
# Copyright (C) 2018 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dslmngr
PKG_VERSION:=1.1.0

LOCAL_DEV=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=3eb41e3f0984f0cd28ddc931f8f4672fadd209da
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/dslmngr.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE


include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),y)
  TARGET_PLATFORM=BROADCOM
else ifeq ($(CONFIG_TARGET_iopsys_ramips),y)
  TARGET_PLATFORM=MEDIATEK
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
  TARGET_PLATFORM=MARVELL
else ifeq ($(CONFIG_TARGET_intel_mips),y)
  TARGET_PLATFORM=INTEL
else
  $(info Unexpected CONFIG_TARGET)
endif

export TARGET_PLATFORM

define Package/dslmngr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=XDSL status and configration utility
  DEPENDS:=+libdsl +libuci +libubox +ubus +libpthread +libnl-genl +libeasy
endef

define Package/dslmngr/description
 This package can be used to configure and provide status about
 the XDSL subsystem through UBUS.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-I$(STAGING_DIR)/usr/include/xdsl \
	-D_GNU_SOURCE

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	FPIC="$(FPIC)"

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
	rsync -r --exclude=.* ~/git/dslmngr/ $(PKG_BUILD_DIR)/
endef
endif

define Build/Compile
	+$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
endef

define Package/dslmngr/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dslmngr $(1)/sbin/
endef

$(eval $(call BuildPackage,dslmngr))
