#
# Copyright (C) 2013 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=fbt
PKG_VERSION:=0.1

PKG_SOURCE_VERSION:=dcb56bcdebe7139940635f9327ee38ccbad5e2c0
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@private.inteno.se:ifbt.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/fbt
	CATEGORY:=Utilities
	DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c
	TITLE:=Fast BSS Transition
endef

define Package/fbt/description
	fbt is Iopsys application for fast BSS transition
endef

define Package/fbt/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fbt $(1)/sbin/
endef

$(eval $(call BuildPackage,fbt))
