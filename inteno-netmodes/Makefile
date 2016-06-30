#
# Copyright (C) 2016 Inteno
#

include $(TOPDIR)/rules.mk

PKG_NAME:=inteno-netmodes
PKG_RELEASE:=1
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/inteno-netmodes
  CATEGORY:=Base system
  TITLE:=Predefined Network Modes
endef

define Package/inteno-netmodes/description
	Predefined Network Modes
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/inteno-netmodes/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,inteno-netmodes))
