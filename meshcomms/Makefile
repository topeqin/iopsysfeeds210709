#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=meshcomms
PKG_VERSION:=1.0.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=8d5808d81d1fc96e4ce4ee682847b4de15b46224
PKG_SOURCE_URL:=https://dev.iopsys.eu/fork/meshcomms.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=BSD2+Patent
PKG_LICENSE_FILES:=LICENSE

PLATFORM := linux
FLAVOUR  := iopsys

export PLATFORM
export FLAVOUR

include $(INCLUDE_DIR)/package.mk

define Package/meshcomms
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Mesh agent
  DEPENDS:=+libpcap +libopenssl +libubox +libubus +libblobmsg-json
endef

define Package/meshcomms/description
 meshComms is an open source implementation of IEEE 1905.1a that is an output
 of the Broadband Forum Open Broadband - Multi Access Point (OB-MAP) project.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE \
        -DDO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS

ifneq ($(CONFIG_BIG_ENDIAN),)
TARGET_CFLAGS += -D_HOST_IS_BIG_ENDIAN_=1
else
TARGET_CFLAGS += -D_HOST_IS_LITTLE_ENDIAN_=1
endif

#define Build/Prepare
#        $(CP) -rf ./meshcomms/* $(PKG_BUILD_DIR)/
#endef

define Package/meshcomms/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/meshcomms.conf $(1)/etc/config/meshcomms
	$(INSTALL_BIN) ./files/meshcomms.init $(1)/etc/init.d/meshcomms
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/al_entity $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,meshcomms))
