# Copyright (C) 2017 PIVA Software <www.pivasoftware.com>
# 	Author: OMAR Kallel <omar.kallel@pivasoftware.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=tr064
PKG_VERSION:=1.0
PKG_SOURCE_URL:=https://dev.iopsys.eu/suite/tr-064.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=e53d492a09c433718a520987c419cb6a4d4ae8dc
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=LGPL-2.1-only Apache-2.0
PKG_CONFIG_DEPENDS:= \
	CONFIG_TR064_DEBUG \
	CONFIG_TR064_DEVEL

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/tr064
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=tr064
  DEPENDS:=+libubus +libuci +libubox +libmicroxml +libjson-c +libpthread +libopenssl +libubus +libubox
endef

define Package/tr064/description
	TR-064 protocol
endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE

TARGET_LDFLAGS += \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += \
	--with-uci-include-path=$(STAGING_DIR)/usr/include \
	--with-libubox-include-path=$(STAGING_DIR)/usr/include \
	--with-libubus-include-path=$(STAGING_DIR)/usr/include

ifeq ($(CONFIG_TR064_DEBUG),y)
CONFIGURE_ARGS += \
	--enable-debug
endif

ifeq ($(CONFIG_TR064_DEVEL),y)
CONFIGURE_ARGS += \
	--enable-devel
endif

CONFIGURE_ARGS += \
	--enable-jsonc=1

define Package/tr064/conffiles
/etc/config/tr064
endef

define Package/tr064/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/upnp-md
	$(INSTALL_DIR) $(1)/etc/upnp-md/web
	$(INSTALL_DIR) $(1)/etc/upnp-md/x509
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/upnp-md-pupnp/upnp-md $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/web/*.xml $(1)/etc/upnp-md/web
	$(CP) $(PKG_BUILD_DIR)/tools/parse_ftp_server_log.sh $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/tools/kill_child.sh $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/x509/*.pem $(1)/etc/upnp-md/x509
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/upnp-md.conf $(1)/etc/upnp-md
	$(CP) $(PKG_BUILD_DIR)/conf/DMconf.xml $(1)/etc/upnp-md
	$(CP) $(PKG_BUILD_DIR)/conf/CPID.csv $(1)/etc/upnp-md
	$(CP) $(PKG_BUILD_DIR)/conf/tr064 $(1)/etc/config
	$(CP) $(PKG_BUILD_DIR)/conf/tr064d $(1)/etc/init.d
	chmod 0744 $(1)/etc/init.d/tr064d
endef

$(eval $(call BuildPackage,tr064))
