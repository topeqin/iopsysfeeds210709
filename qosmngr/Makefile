#
# Copyright (C) 2020 IOPSYS
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qosmngr
PKG_VERSION:=1.0.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/qosmngr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=QoS Manager
  DEPENDS:=@(TARGET_iopsys_brcm63xx_arm)
endef

define Package/qosmngr/description
	Configures L2 QoS and collects queue statistics
endef

#define Build/Prepare
#        $(CP) -rf ./qosmngr/* $(PKG_BUILD_DIR)/
#endef

define Build/Compile
endef

define Package/qosmngr/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,qosmngr))
