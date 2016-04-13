#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=owsd
PKG_VERSION:=0.9
PKG_RELEASE:=1

PKG_SOURCE_PROTO=git
PKG_SOURCE_URL:=git@public.inteno.se:owsd.git
PKG_SOURCE_VERSION:=64a9b07e0578dfbc67fb4a72bf1498e8cb3d59b1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=${PKG_NAME}-${PKG_VERSION}
PKG_MAINTAINER:=Sartura Support for Inteno <support-inteno@sartura.hr>
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/owsd/default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ubus +ubox +libjson-c +libblobmsg-json +rpcd
  TITLE:=owsd daemon
endef

define Package/owsd
	$(call Package/$(PKG_NAME)/default)
	TITLE += (default)
	DEPENDS += +libwebsockets-openssl
#	DEPENDS += +libwebsockets-nossl
	VARIANT:=owsd
endef

#ifeq ($(BUILD_VARIANT),owsd)
#	CMAKE_OPTIONS += -OWSD_OPENSSL_SUPPORT=OFF
#	CMAKE_OPTIONS += -OWSD_WITH_SSL=OFF
#endif

define Package/owsd-openssl
	$(call Package/$(PKG_NAME)/default)
	TITLE += (With SSL support)
	DEPENDS += +libwebsockets-openssl
	VARIANT:=openssl
endef

define Package/owsd-testdata
	$(call Package/$(PKG_NAME)/default)
	TITLE += (Test certs and rpcd ACLs for running automated tests)
	DEPENDS := owsd
endef

#ifeq ($(BUILD_VARIANT),openssl)
#	CMAKE_OPTIONS += -OWSD_OPENSSL_CLIENT_CERTS=/etc/ssl/certs
#	CMAKE_OPTIONS += -OWSD_OPENSSL_SUPPORT=ON
#	CMAKE_OPTIONS += -OWSD_WITH_SSL=ON
#endif


define Package/owsd/description
 Web socket ubus daemon
endef

define Package/owsd-testdata/install
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/owsd-test.json $(1)/usr/share/rpcd/acl.d/owsd-test.json
	$(INSTALL_DIR) $(1)/usr/share/owsd/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/res/cert.pem $(1)/usr/share/owsd/cert.pem
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/res/key.pem $(1)/usr/share/owsd/key.pem
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
$(eval $(call BuildPackage,owsd-openssl))
$(eval $(call BuildPackage,owsd-testdata))
