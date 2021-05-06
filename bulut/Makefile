#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bulut
PKG_VERSION:=0.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/bulut/bulut-gw-client.git
PKG_SOURCE_VERSION:=227700c44817afa2c392fa08bf4cf70fa6177f01

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/bulut
	CATEGORY:=Utilities
	DEPENDS:=
	TITLE:=bulut
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include

define Package/bulut/description
	obuspa keys
endef

define Package/bulut/install
	$(CP)  $(PKG_BUILD_DIR)/files/* $(1)/
endef

$(eval $(call BuildPackage,bulut))
