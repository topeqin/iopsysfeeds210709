#
# Copyright (C) 2018 Inteno
#

include $(TOPDIR)/rules.mk

PKG_NAME:=owsd
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO=git
PKG_SOURCE_URL:=http://public.inteno.se/owsd.git
PKG_SOURCE_VERSION:=372743e4c905c9d51988742442b375f0b2bab8db
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=${PKG_NAME}-${PKG_VERSION}
PKG_MAINTAINER:=Sartura Support for Inteno <support-inteno@sartura.hr>
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_CONFIG_DEPENDS:=CONFIG_OWSD_USE_DBUS CONFIG_OWSD_USE_UBUS CONFIG_OWSD_USE_DBUS_UBUS

USE_UBUS-y:=-DWSD_HAVE_UBUS=ON
USE_DBUS-y:=-DWSD_HAVE_DBUS=ON
USE_BOTH-y:=${USE_UBUS-y} ${USE_DBUS-y}

CMAKE_OPTIONS:=${USE_UBUS-${CONFIG_OWSD_USE_UBUS}} \
	${USE_DBUS-${CONFIG_OWSD_USE_DBUS}} \
	${USE_BOTH-${CONFIG_OWSD_USE_DBUS_UBUS}}

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/owsd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libjson-c +libblobmsg-json +libwebsockets +ubox \
	  +OWSD_USE_UBUS:ubus \
	  +OWSD_USE_DBUS:libdbus \
	  +OWSD_USE_DBUS:libxml2 \
	  +OWSD_USE_DBUS:dbus \
	  +OWSD_USE_DBUS_UBUS:ubus \
	  +OWSD_USE_DBUS_UBUS:libdbus \
	  +OWSD_USE_DBUS_UBUS:libxml2 \
	  +OWSD_USE_DBUS_UBUS:dbus
  TITLE:=owsd daemon
  MENU:=1
endef

define Package/owsd/config
       source "$(SOURCE)/Config.in"
endef

define Package/owsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/owsd $(1)/usr/bin/owsd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/owsd.init $(1)/etc/init.d/owsd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/owsd.config $(1)/etc/config/owsd
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/owsd.hotplug $(1)/etc/hotplug.d/iface/55-owsd
#	$(INSTALL_DIR) $(1)/etc/uci-defaults
#	$(INSTALL_BIN) ./files/owsd.uci_default $(1)/etc/uci-defaults/55-owsd-interfaces
endef

define Package/owsd-testdata
	$(call Package/owsd)
	TITLE += (Test certs and rpcd ACLs for running automated tests)
	DEPENDS := owsd +rpcd-mod-file
endef

define Package/owsd/description
 Web socket ubus daemon
endef

define Package/owsd-testdata/install
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/owsd-test.json $(1)/usr/share/rpcd/acl.d/owsd-test.json
	$(INSTALL_DIR) $(1)/usr/share/owsd/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/cert.pem $(1)/usr/share/owsd/cert.pem
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/key.pem $(1)/usr/share/owsd/key.pem

	$(INSTALL_DIR) $(1)/www/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/webdemo/index.html $(1)/www/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/webdemo/script.js $(1)/www/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/webdemo/style.css $(1)/www/
endef

define Package/owsd-testdata/postinst
#!/bin/sh
set -e
uci delete rpcd.owsd_test 2>/dev/null || true
uci set rpcd.owsd_test=login
uci set rpcd.owsd_test.username="owsd_test"
uci set rpcd.owsd_test.password="x"
uci add_list rpcd.owsd_test.read='test-calls'
uci add_list rpcd.owsd_test.read='test-events'
uci commit
endef

define Package/owsd-testdata/prerm
#!/bin/sh
set -e
uci delete rpcd.owsd_test
uci commit
endef

$(eval $(call BuildPackage,owsd))
$(eval $(call BuildPackage,owsd-testdata))
