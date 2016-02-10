include $(TOPDIR)/rules.mk

PKG_NAME:=btle_alarm
PKG_VERSION:=1.0.6
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=b505d7ae1524a213ca3de7f8ee15a7d51c6bbbd5
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@iopsys.inteno.se:btle_alarm

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/btle_alarm
  SECTION:=base
  CATEGORY:=Utilities
  TITLE:=Ethernet bridging configuration utility
  #DESCRIPTION:=This variable is obsolete. use the Package/name/description define instead!
  URL:=http://btle_alarm.sourceforge.net/
  DEPENDS:=+bluez +libncurses
endef

define Package/btle_alarm/description
 Ethernet bridging configuration utility
 Manage ethernet bridging; a way to connect networks together to
 form a larger network.
endef

define Package/btle_alarm/install

	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/btle_alarm $(1)/sbin/

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DATA) ./files/btle_alarm.conf $(1)/etc/config/btle_alarm

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/etc/init.d/* $(1)/etc/init.d/

endef

$(eval $(call BuildPackage,btle_alarm))
