#
# Copyright (C) 2018 IOPSYS Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=endptmngr
PKG_VERSION:=0.5

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/endptmngr.git
PKG_SOURCE_VERSION:=d3938443caffea15641bff72837d2de0cf87d62c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

export BUILD_DIR

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

# All config variable that are passed to the make invocation, directly or
# indirectly. This ensures that the package is rebuilt on config-changes.
PKG_CONFIG_DEPENDS:=CONFIG_TARGET_BOARD

export CONFIG_BRCM_SDK_VER_504002
export CONFIG_BCM_CHIP_ID

include $(INCLUDE_DIR)/package.mk

define Package/endptmngr/config
	source "$(SOURCE)/Config.in"
endef

define Package/endptmngr
  CATEGORY:=Utilities
  TITLE:=Broadcom Voice Endpoint Manager
  URL:=
  DEPENDS:= +libubox +ubus +libpicoevent +uci +bcmkernel @TARGET_HAS_VOICE @BCM_VOICE
endef

define Package/endptmngr/description
	endptmngr
endef

define Package/endptmngr/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/endptmngr $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,endptmngr))
