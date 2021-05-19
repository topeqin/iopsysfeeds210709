#
# Copyright (C) 2020 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icwmp
PKG_VERSION:=7.0.3-2021-05-19
PKG_FIXUP:=autoreconf
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/icwmp.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=53d5b0503a05ad17fd5b0701e89aba2c39b24c23
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS:= \
	CONFIG_CWMP_ACS_MULTI \
	CONFIG_CWMP_ACS_HDM \
	CONFIG_CWMP_DEBUG \
	CONFIG_CWMP_DEVEL_DEBUG

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

CWMP_REVISION=$(shell svnversion ./src/ -n|cut -f2 -d:)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=TRx69
  TITLE:=CWMP client
  DEPENDS:=+libuci +libmicroxml +libubox +jshn +libubus +libblobmsg-json +libpthread +ubusd +shflags +getopt +zlib +libjson-c +libopenssl +curl +libcurl
endef

define Package/$(PKG_NAME)/description
 A free client implementation of CWMP (TR-069) protocol
endef

define Package/$(PKG_NAME)/config
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

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/icwmpd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/icwmpd $(1)/usr/sbin/
	$(CP) ./files/* $(1)/
endef

define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Enabling rc.d symlink for icwmpd"
		/etc/init.d/icwmpd enable
	fi
	exit 0
endef

define Package/$(PKG_NAME)/prerm
	#!/bin/sh
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Disabling rc.d symlink for icwmpd"
		/etc/init.d/icwmpd disable
	fi
	exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
