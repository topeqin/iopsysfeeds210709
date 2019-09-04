#
# Copyright (C) 2019 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=crashlog
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=none

include $(INCLUDE_DIR)/package.mk

define Package/crashlog
  CATEGORY:=Utilities
  TITLE:=Handling kernel crash logs
endef

define Package/crashlog/description
	Handling kernel crash logs.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/crashlog/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,crashlog))
