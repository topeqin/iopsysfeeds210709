include $(TOPDIR)/rules.mk

PKG_NAME:=btle_alarm
PKG_VERSION:=1.0.6
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/btle_alarm-utils-$(PKG_VERSION)
PKG_SOURCE:=btle_alarm-utils-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/btle_alarm
  SECTION:=base
  CATEGORY:=Utillities
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
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/btle_alarm/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/btle_alarm $(1)/usr/bin/
endef

$(eval $(call BuildPackage,btle_alarm))
