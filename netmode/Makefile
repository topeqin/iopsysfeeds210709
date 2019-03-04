include $(TOPDIR)/rules.mk

PKG_NAME:=netmode
PKG_VERSION:=0.2.0

PKG_SOURCE_VERSION:=67e28e4db71f6eea7e8c988f5867e8647bf3b345
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/netmoded

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/netmode
	CATEGORY:=Base system
	DEPENDS:=+fping +ubus +libubox +libuci
	TITLE:=Predefined Network Modes
endef

define Package/netmode/description
	Predefined Network Modes
endef

define Package/netmode/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/netmoded $(1)/sbin/
endef

$(eval $(call BuildPackage,netmode))
