#
# Copyright (C) 2013-2020 iopsys
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mcastmngr
PKG_VERSION:=1.0.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/mcastmngr
	CATEGORY:=Utilities
	TITLE:=multicast packets manager daemon
endef

define Package/mcastmngr/description
	Configures IGMP and MLD snooping and proxy
endef

#define Build/Prepare
#        $(CP) -rf ./mcastmngr/* $(PKG_BUILD_DIR)/
#endef

define Build/Compile
endef

define Package/mcastmngr/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,mcastmngr))
