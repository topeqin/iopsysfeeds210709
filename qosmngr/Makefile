#
# Copyright (C) 2020 IOPSYS
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qosmngr
PKG_VERSION:=1.0.0

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=03df56c6eb7c6737ce95576e89c915df77396953
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/qosmngr.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/qosmngr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=QoS Manager
  DEPENDS:=@(TARGET_iopsys_brcm63xx_arm) +libuci +libubox +libubus +libblobmsg-json +libjson-c +libqos
endef

define Package/qosmngr/description
	Configures L2 QoS and collects queue statistics
endef

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
        $(CP) -rf ./qosmngr/* $(PKG_BUILD_DIR)/
endef
endif

define Package/qosmngr/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qosmngr $(1)/usr/sbin
endef

$(eval $(call BuildPackage,qosmngr))
