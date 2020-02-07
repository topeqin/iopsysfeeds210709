#
# Copyright (C) 2019 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icwmp
PKG_VERSION:=4.0-2020-01-21
PKG_FIXUP:=autoreconf
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/icwmp.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=c2aef839594edd4cef580b105d510c2ad09bf6a5
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS:= \
	CONFIG_CWMP_ACS_MULTI \
	CONFIG_CWMP_ACS_HDM \
	CONFIG_CWMP_DEBUG \
	CONFIG_CWMP_DEVEL_DEBUG

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

CWMP_REVISION=$(shell svnversion ./src/ -n|cut -f2 -d:)

include $(INCLUDE_DIR)/package.mk

define Package/icwmp_stun
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=TR-069 stun Client
  DEPENDS:=+PACKAGE_icwmp_stun:libubus +PACKAGE_icwmp_stun:libuci +PACKAGE_icwmp_stun:libubox +PACKAGE_icwmp_stun:libjson-c +PACKAGE_icwmp_stun:libopenssl +PACKAGE_icwmp_stun:libblobmsg-json
endef

define Package/icwmp_xmpp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=TR-069 xmpp feature
  DEPENDS:=+PACKAGE_icwmp_xmpp:libuci +PACKAGE_icwmp_xmpp:libubox +PACKAGE_icwmp_xmpp:libexpat +PACKAGE_icwmp_xmpp:libstrophe
endef

define Package/icwmp_twamp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=TR-069 twamp feature
  DEPENDS:=+PACKAGE_icwmp_twamp:libuci
endef

define Package/icwmp_udpechoserver
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=TR-069 udpechoserver feature
  DEPENDS:=+PACKAGE_icwmp_udpechoserver:libuci
endef

define Package/icwmp_bulkdata
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=TR-069 BulkData Collection
  DEPENDS:=+PACKAGE_icwmp_bulkdata:libubus +PACKAGE_icwmp_bulkdata:libuci +PACKAGE_icwmp_bulkdata:libubox +PACKAGE_icwmp_bulkdata:libjson-c +PACKAGE_icwmp_bulkdata:libcurl +PACKAGE_icwmp_bulkdata:curl +PACKAGE_icwmp_bulkdata:libblobmsg-json +PACKAGE_icwmp_bulkdata:libbbfdm
endef

define Package/icwmp-tr098
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CWMP client for TR-098 Data Model
  DEPENDS:=+PACKAGE_icwmp-tr098:libuci +PACKAGE_icwmp-tr098:libmicroxml +PACKAGE_icwmp-tr098:libubox +PACKAGE_icwmp-tr098:jshn +PACKAGE_icwmp-tr098:libubus +PACKAGE_icwmp-tr098:libblobmsg-json +PACKAGE_icwmp-tr098:libpthread +PACKAGE_icwmp-tr098:ubusd +PACKAGE_icwmp-tr098:shflags +PACKAGE_icwmp-tr098:getopt +PACKAGE_icwmp-tr098:zlib +PACKAGE_icwmp-tr098:libjson-c +PACKAGE_icwmp-tr098:libopenssl +PACKAGE_icwmp-tr098:curl +PACKAGE_icwmp-tr098:libcurl +PACKAGE_icwmp-tr098:libtr098
endef

define Package/icwmp/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CWMP client
  DEPENDS:=+libuci +libmicroxml +libubox +jshn +libubus +libblobmsg-json +libpthread +ubusd +shflags +getopt +zlib +libjson-c +libopenssl +curl +libbbfdm
endef

define Package/icwmp/description
 A free client implementation of CWMP (TR-069) protocol
endef

define Package/icwmp-curl
  $(call Package/icwmp/Default)
  TITLE+= (using libcurl)
  DEPENDS+= +PACKAGE_icwmp-curl:libcurl
  VARIANT:=curl
endef

define Package/icwmp-zstream
  $(call Package/icwmp/Default)
  TITLE+= (using libzstream)
  DEPENDS+= +PACKAGE_icwmp-zstream:libzstream
  VARIANT:=zstream
endef

define Package/icwmp-curl/config
	source "$(SOURCE)/Config_cwmp.in"
endef

USE_LOCAL=$(shell ls ./src/ 2>/dev/null >/dev/null && echo 1)
ifneq ($(USE_LOCAL),)
define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
endif

TARGET_CFLAGS += \
	-D_GNU_SOURCE -D_AADJ

ifeq ($(CONFIG_PACKAGE_icwmp-tr098),y)
CONFIGURE_ARGS += \
	--enable-icwmp_tr098
endif

ifeq ($(CONFIG_PACKAGE_icwmp_xmpp),y)
CONFIGURE_ARGS += \
	--enable-icwmp_xmpp
endif

ifeq ($(CONFIG_PACKAGE_icwmp_stun),y)
CONFIGURE_ARGS += \
	--enable-icwmp_stun
endif

ifeq ($(CONFIG_PACKAGE_icwmp_udpechoserver),y)
CONFIGURE_ARGS += \
	--enable-icwmp_udpechoserver
endif

ifeq ($(CONFIG_PACKAGE_icwmp_twamp),y)
CONFIGURE_ARGS += \
	--enable-icwmp_twamp
endif

ifeq ($(CONFIG_PACKAGE_icwmp_bulkdata),y)
CONFIGURE_ARGS += \
	--enable-icwmp_bulkdata
endif

ifneq ($(CWMP_REVISION)_,_)
ifneq ($(CWMP_REVISION),exported)
ifneq ($(CWMP_REVISION),Unversioned directory)
TARGET_CFLAGS += "-DCWMP_REVISION=\\\"$(CWMP_REVISION)\\\""
TARGET_LDFLAGS += "-DCWMP_REVISION=\\\"$(CWMP_REVISION)\\\""
endif
endif
endif

TARGET_LDFLAGS += \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += \
	--with-uci-include-path=$(STAGING_DIR)/usr/include \
	--with-libubox-include-path=$(STAGING_DIR)/usr/include \
	--with-libubus-include-path=$(STAGING_DIR)/usr/include
	
ifeq ($(BUILD_VARIANT),zstream)
CONFIGURE_ARGS += \
	--enable-http=zstream \
	--with-zstream-include-path=$(STAGING_DIR)/usr/include
endif

ifeq ($(BUILD_VARIANT),curl)
CONFIGURE_ARGS += \
	--enable-http=curl
endif

ifeq ($(CONFIG_CWMP_ACS_MULTI),y)
CONFIGURE_ARGS += \
	--enable-acs=multi
endif

ifeq ($(CONFIG_CWMP_ACS_HDM),y)
CONFIGURE_ARGS += \
	--enable-acs=hdm
endif

ifeq ($(CONFIG_CWMP_DEBUG),y)
CONFIGURE_ARGS += \
	--enable-debug
endif

ifeq ($(CONFIG_CWMP_DEVEL_DEBUG),y)
CONFIGURE_ARGS += \
	--enable-devel
endif

define Package/icwmp-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) $(1)/etc/icwmpd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/bin/icwmpd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/cwmp $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/firewall.cwmp $(1)/etc/firewall.cwmp
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init/icwmpd.init $(1)/etc/init.d/icwmpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uci-defaults/* $(1)/etc/uci-defaults/
ifeq ($(CONFIG_CWMP_SCRIPTS_FULL),y)
	$(INSTALL_DIR) $(1)/usr/share/icwmp
	$(CP) $(PKG_BUILD_DIR)/scripts/defaults $(1)/usr/share/icwmp
	$(CP) $(PKG_BUILD_DIR)/scripts/functions $(1)/usr/share/icwmp
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/icwmp.sh $(1)/usr/sbin/icwmp
endif
	$(CP) ./files/* $(1)/
endef

define Package/icwmp-tr098/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/bin/icwmp_tr098d $(1)/usr/sbin
endef

define Package/icwmp_stun/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/icwmp_stund $(1)/usr/sbin/icwmp_stund
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init/icwmp_stund $(1)/etc/init.d/icwmp_stund
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/cwmp_stun $(1)/etc/config
endef

define Package/icwmp_xmpp/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/icwmp_xmppd $(1)/usr/sbin/icwmp_xmppd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init/icwmp_xmppd $(1)/etc/init.d/icwmp_xmppd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/cwmp_xmpp $(1)/etc/config
	$(CP) ./xmpp-files/* $(1)/
endef

define Package/icwmp_udpechoserver/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/icwmp_udpechoserverd $(1)/usr/sbin/icwmp_udpechoserverd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init/icwmp_udpechoserverd $(1)/etc/init.d/icwmp_udpechoserverd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/cwmp_udpechoserver $(1)/etc/config
endef

define Package/icwmp_twamp/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/icwmp_twampd $(1)/usr/sbin/icwmp_twampd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init/icwmp_twampd $(1)/etc/init.d/icwmp_twampd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/cwmp_twamp $(1)/etc/config
endef

define Package/icwmp_bulkdata/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/icwmp_bulkdatad $(1)/usr/sbin/icwmp_bulkdatad
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init/icwmp_bulkdatad $(1)/etc/init.d/icwmp_bulkdatad
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/cwmp_bulkdata $(1)/etc/config
endef

define Package/icwmp-$(BUILD_VARIANT)/postinst
	#!/bin/sh
	echo "$(CWMP_BKP_FILE)" >> $${IPKG_INSTROOT}/etc/sysupgrade.conf
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Enabling rc.d symlink for icwmpd"
		/etc/init.d/icwmpd enable
	fi
	exit 0
endef

define Package/icwmp-$(BUILD_VARIANT)/prerm
	#!/bin/sh
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Disabling rc.d symlink for icwmpd"
		/etc/init.d/icwmpd disable
	fi
	exit 0
endef

$(eval $(call BuildPackage,icwmp-curl))
$(eval $(call BuildPackage,icwmp_stun))
$(eval $(call BuildPackage,icwmp_xmpp))
$(eval $(call BuildPackage,icwmp_udpechoserver))
$(eval $(call BuildPackage,icwmp_twamp))
$(eval $(call BuildPackage,icwmp_bulkdata))
$(eval $(call BuildPackage,icwmp-tr098))
#$(eval $(call BuildPackage,icwmp-zstream))
