include $(TOPDIR)/rules.mk

PKG_NAME:=netmode
PKG_VERSION:=0.2.0

PKG_SOURCE_VERSION:=fbd7dcfab03df19b3c32675940e0aee708c7cf75
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/netmoded

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
