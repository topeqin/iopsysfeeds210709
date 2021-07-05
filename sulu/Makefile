#
# Copyright (C) 2021 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sulu
PKG_VERSION:=0.2.17

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/sulu.git
PKG_SOURCE_VERSION:=06411282a6c2d02d21599786c0dd12c00c711847

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_RELEASE=$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=PROPRIETARY IOPSYS
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/sulu
	SECTION:=sulu
	CATEGORY:=Utilities
	MENU=1
	TITLE:=SULU-CE ReactJS based Web UI Package
	DEPENDS:=+nginx
endef

define Package/sulu/description
	SULU-CE ReactJS based Web UI.
endef

define Package/sulu/install
	$(INSTALL_DIR) $(1)/sulu
	$(CP) $(PKG_BUILD_DIR)/dist/* $(1)/sulu
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,sulu))

