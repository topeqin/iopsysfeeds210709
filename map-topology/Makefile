#
# Copyright (C) 2019 iopsys
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=map-topology
PKG_VERSION:=0.1

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_VERSION:=2242b834c82eaf064022c76a2f52eec20de351fe
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/map-topology.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
endif

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=PROPRIETARY IOPSYS
PKG_LICENSE_FILES:=LICENSE
include $(INCLUDE_DIR)/package.mk

define Package/map-topology
	CATEGORY:=Utilities
	DEPENDS:=+libubox +ubus +libpthread +libuci +libeasy +libmaputils
	TITLE:=Map topology daemon
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include

define Package/map-topology/description
	gathers topology information and presents it as json structure
endef

MAKE_PATH:=src

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
        $(CP) -rf ~/git/map-topology/* $(PKG_BUILD_DIR)/
endef
endif

define Package/map-topology/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/topo1905d $(1)/sbin/
endef

$(eval $(call BuildPackage,map-topology))
