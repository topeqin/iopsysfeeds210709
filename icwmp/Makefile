#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icwmp
PKG_VERSION:=4.0-2019-06-20
PKG_FIXUP:=autoreconf
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/icwmp.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=0cf3a9b69a71ec6ffe149991c532143290cde688
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)


PKG_CONFIG_DEPENDS:= \
	CONFIG_CWMP_ACS_MULTI \
	CONFIG_CWMP_ACS_HDM \
	CONFIG_CWMP_DEBUG \
	CONFIG_CWMP_DEVEL_DEBUG

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

CWMP_REVISION=$(shell svnversion ./src/ -n|cut -f2 -d:)

include $(INCLUDE_DIR)/package.mk

define Package/libdatamodel
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for broadband-forum data model
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c
endef

define Package/icwmp_stun
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=TR-069 stun Client
	DEPENDS:=+libubus +libuci +libubox +libjson-c +libopenssl +libblobmsg-json
endef

define Package/icwmp_xmpp
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=TR-069 xmpp feature
	DEPENDS:=+libuci +libubox +libexpat +libstrophe
endef

define Package/icwmp_twamp
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=TR-069 twamp feature
	DEPENDS:=+libuci
endef

define Package/icwmp_udpechoserver
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=TR-069 udpechoserver feature
	DEPENDS:=+libuci
endef

define Package/icwmp/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CWMP client
  DEPENDS:=+libuci +libmicroxml +libubox +jshn +libubus +libblobmsg-json +libpthread +ubusd +shflags +getopt +zlib +libjson-c +libopenssl +libexpat +libstrophe +curl +libtrace +libdatamodel
endef

define Package/icwmp/description
 A free client implementation of CWMP (TR-069) protocol
endef

define Package/icwmp-curl
  $(call Package/icwmp/Default)
  TITLE+= (using libcurl)
  DEPENDS+= +libcurl
  VARIANT:=curl
endef

define Package/icwmp-zstream
  $(call Package/icwmp/Default)
  TITLE+= (using libzstream)
  DEPENDS+= +libzstream
  VARIANT:=zstream
endef

define Package/icwmp-zstream/config
	source "$(SOURCE)/Config_cwmp.in"
endef

define Package/libdatamodel/config
	source "$(SOURCE)/Config_datamodel.in"
endef

USE_LOCAL=$(shell ls ./src/ 2>/dev/null >/dev/null && echo 1)
ifneq ($(USE_LOCAL),)
define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
endif

ifeq ($(CONFIG_TARGET_iopsys_ramips),y)
TARGET_CFLAGS += -DEX400
endif

TARGET_CFLAGS += -DCUSTOM_PREFIX=\\\"$(CONFIG_LIBDATAMODEL_VENDOR_PREFIX)\\\"

TARGET_CFLAGS += \
	-D_GNU_SOURCE -D_AADJ

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
	
ifeq ($(CONFIG_UPNP_TR064),y)
CONFIGURE_ARGS += \
	--enable-upnptr064
endif
	
ifeq ($(CONFIG_XMPP_ENABLE),y)
CONFIGURE_ARGS += \
	--enable-xmpp
endif
	
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

define Package/libdatamodel/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libdatamodel.so* $(1)/lib/
endef

define Package/icwmp-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) $(1)/etc/icwmpd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/icwmpd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/cwmp $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/dmmap $(1)/etc/icwmpd
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/firewall.cwmp $(1)/etc/firewall.cwmp
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/init/icwmpd.init $(1)/etc/init.d/icwmpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uci-defaults/90-cwmpfirewall $(1)/etc/uci-defaults/90-cwmpfirewall
ifeq ($(CONFIG_CWMP_SCRIPTS_FULL),y)
	$(INSTALL_DIR) $(1)/usr/share/icwmp
	$(CP) $(PKG_BUILD_DIR)/scripts/defaults $(1)/usr/share/icwmp
	$(CP) $(PKG_BUILD_DIR)/scripts/functions $(1)/usr/share/icwmp
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/icwmp.sh $(1)/usr/sbin/icwmp
endif
	$(CP) ./files/* $(1)/
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

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/libdatamodel
	$(CP) $(PKG_BUILD_DIR)/dm/*.h $(1)/usr/include/libdatamodel
	$(CP) $(PKG_BUILD_DIR)/dm/dmtree/common/root.h $(1)/usr/include/libdatamodel
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libdatamodel.so* $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libdatamodel.a $(1)/lib
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
$(eval $(call BuildPackage,libdatamodel))
$(eval $(call BuildPackage,icwmp_stun))
$(eval $(call BuildPackage,icwmp_xmpp))
$(eval $(call BuildPackage,icwmp_udpechoserver))
$(eval $(call BuildPackage,icwmp_twamp))
$(eval $(call BuildPackage,icwmp-zstream))
