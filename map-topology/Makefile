#
# Copyright (C) 2020 iopsys
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=map-topology
PKG_VERSION:=1.5.13

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_VERSION:=2a20b82c95e90b06cb47a863ef01fc800c3aaad6
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/map-topology.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=PROPRIETARY IOPSYS
PKG_LICENSE_FILES:=LICENSE
include $(INCLUDE_DIR)/package.mk

define Package/map-topology
	CATEGORY:=Utilities
	DEPENDS:=+libubox +ubus +libpthread +libuci +libeasy \
		+libieee1905 +libavahi-nodbus-support
	TITLE:=Utility to build topology of a multi-AP network
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include

define Package/map-topology/description
	Constructs network topology and show it as json structure over UBUS
endef

MAKE_PATH:=src

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
        $(CP) -rf ~/git/map-topology/* $(PKG_BUILD_DIR)/
endef
endif

define Package/map-topology/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/topologyd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,map-topology))
