#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=owsd
PKG_VERSION:=0.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO=git
PKG_SOURCE_URL:=http://public.inteno.se/owsd.git
PKG_SOURCE_VERSION:=05eadc177ba8acf91a18caae2ea1a9a4247a9369
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
	DEPENDS += +libwebsockets-nossl
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

#ifeq ($(BUILD_VARIANT),openssl)
#	CMAKE_OPTIONS += -OWSD_OPENSSL_CLIENT_CERTS=/etc/ssl/certs
#	CMAKE_OPTIONS += -OWSD_OPENSSL_SUPPORT=ON
#	CMAKE_OPTIONS += -OWSD_WITH_SSL=ON
#endif


define Package/owsd/description
 Web socket ubus daemon
endef

define Package/owsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/owsd $(1)/usr/bin/
endef

$(eval $(call BuildPackage,owsd))
$(eval $(call BuildPackage,owsd-openssl))
