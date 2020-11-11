#
# Copyright (C) 2018 IOPSYS Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_RELEASE:=1
PKG_VERSION:=0.4
PKG_SOURCE_VERSION:=b796e0c5f67579f231e3b726eec6324d8c1b1adc
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

ifeq ($(CONFIG_ENDPT_OPEN),y)
BRCM_KERNEL_PROFILE=$(shell echo $(CONFIG_BCM_KERNEL_PROFILE) | sed s/\"//g)
PKG_SOURCE:=endptmngr-$(BRCM_KERNEL_PROFILE)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL:=http://download.iopsys.eu/iopsys/opensdk/
PKG_NAME:=endptmngr-open
PATCH_DIR:=
PKG_HASH:=skip
else
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/endptmngr.git
PKG_SOURCE_PROTO:=git
PKG_NAME:=endptmngr
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
endif

export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

# All config variable that are passed to the make invocation, directly or
# indirectly. This ensures that the package is rebuilt on config-changes.
PKG_CONFIG_DEPENDS := \
	CONFIG_TARGET_BOARD

export CONFIG_BRCM_SDK_VER_504001
export CONFIG_BRCM_SDK_VER_504002
export CONFIG_BRCM_SDK_VER_504003
export CONFIG_BRCM_SDK_VER_504004
export CONFIG_BRCM_SDK_VER_504005


include $(INCLUDE_DIR)/package.mk

define Package/endptmngr/config
	source "$(SOURCE)/Config.in"
endef

define Package/endptmngr
  CATEGORY:=Utilities
  TITLE:=Brcmslic
  URL:=
  DEPENDS:= +libubox +ubus +libpicoevent +bcmkernel @TARGET_HAS_VOICE @BCM_VOICE
endef

define Package/endptmngr/description
	endptmngr
endef

ifeq ($(CONFIG_ENDPT_OPEN),y)

define Build/Compile
endef

endif


define Package/endptmngr/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d/
	cp $(PKG_BUILD_DIR)/files/etc/init.d/* $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/endptmngr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,endptmngr))
