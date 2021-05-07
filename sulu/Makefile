#
# Copyright (C) 2021 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sulu
PKG_VERSION:=0.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/sulu.git
PKG_SOURCE_VERSION:=f2502d984b3ecd6d97529ea128142609c0165289

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_RELEASE=$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/sulu
#  $(Package/sulu/default)
  SECTION:=sulu
  CATEGORY:=Utilities
  MENU=1
  TITLE:=SULU-CE ReactJS based Web UI Package
endef

define Package/sulu/description
 SULU-CE ReactJS based Web UI.
endef

define Package/sulu/install
	$(INSTALL_DIR) $(1)/www
	$(CP) $(PKG_BUILD_DIR)/out/* $(1)/www
#	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,sulu))

