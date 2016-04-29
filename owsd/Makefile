#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=owsd
PKG_VERSION:=0.94
PKG_RELEASE:=1

PKG_SOURCE_PROTO=git
PKG_SOURCE_URL:=git@public.inteno.se:owsd.git
PKG_SOURCE_VERSION:=18825d54a38d137fb26f418d1d2f7bb2991eaf89
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=${PKG_NAME}-${PKG_VERSION}
PKG_MAINTAINER:=Sartura Support for Inteno <support-inteno@sartura.hr>
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/owsd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ubus +ubox +libjson-c +libblobmsg-json +rpcd +libwebsockets
  TITLE:=owsd daemon
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

define Package/owsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/owsd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/owsd.init $(1)/etc/init.d/owsd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/owsd $(1)/etc/config/owsd
endef

$(eval $(call BuildPackage,owsd))
$(eval $(call BuildPackage,owsd-testdata))
