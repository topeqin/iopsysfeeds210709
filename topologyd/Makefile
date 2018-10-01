#
# Copyright (C) 2013 Inteno
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=topologyd
PKG_VERSION:=0.1

PKG_SOURCE_VERSION:=c0c93b0e4087ca77e0ef8b5e01cad87ba0ec33f2
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/topologyd.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/topologyd
	CATEGORY:=Utilities
	DEPENDS:=+libubox +ubus +libpthread +libopenssl +libnl-genl +libnl +libuci
	TITLE:=topology daemon
endef

define Package/topologyd/description
	gathers topology information and presents it as json structure
endef

define Package/topologyd/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/topologyd $(1)/sbin/
endef

$(eval $(call BuildPackage,topologyd))
