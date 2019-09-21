#
# Copright (C) 2018 The Internet Foundation In Sweden
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bbk_cli
PKG_SOURCE_VERSION:=7b810a696c78b746185c11282bdbe3fb7f8c5d4b
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/dotse/bbk.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/bbk_cli
	CATEGORY:=Utilities
	DEPENDS:=+libpthread +libstdcpp
	TITLE:=Bredbandskollen CLI - A bandwidth measurement tool
endef

define Package/bbk_cli/description
	To measure connection speed in an environment that is missing a web browser, 
	for example, in a server, you can use our command line interface bbk_cli, 
	which is available for some of the most common operating systems.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src/cli CROSS_COMPILE="$(TARGET_CROSS)"
endef

define Package/bbk_cli/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/cli/cli $(1)/sbin/bbk_cli
endef

$(eval $(call BuildPackage,bbk_cli))
