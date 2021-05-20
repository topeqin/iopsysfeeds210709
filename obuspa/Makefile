#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=obuspa
PKG_VERSION:=4.0.0.2

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=fefad332780c615168d96687f6d854703b04ec6f
PKG_SOURCE_URL:=https://dev.iopsys.eu/fork/obuspa.git
PKG_MAINTAINER:=Vivek Dutta <vivek.dutta@iopsys.eu>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/obuspa
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=USP agent
  DEPENDS:=+libopenssl +libcurl +libsqlite3 +libubox +libubus +uspd +libmosquitto
endef

define Package/obuspa/description
 OB-USP-AGENT is a system daemon providing a User Services Platform (USP) Agent.
endef

define Package/obuspa/config
	source "$(SOURCE)/Config.in"
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

ifeq ($(CONFIG_OBUSPA_MTP_ENABLE_STOMP),y)
  CONFIGURE_ARGS += \
	--enable-stomp
else
  CONFIGURE_ARGS += \
	--disable-stomp
endif

ifeq ($(CONFIG_OBUSPA_MTP_ENABLE_MQTT),y)
  CONFIGURE_ARGS += \
	--enable-mqtt
else
  CONFIGURE_ARGS += \
	--disable-mqtt
endif

ifeq ($(CONFIG_OBUSPA_MTP_ENABLE_COAP),y)
  CONFIGURE_ARGS += \
	--enable-coap
else
  CONFIGURE_ARGS += \
	--disable-coap
endif

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
        $(CP) -rf ~/git/obuspa/* $(PKG_BUILD_DIR)/
endef
endif

define Package/obuspa/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/obuspa
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/obuspa $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/obuspa $(1)/etc/init.d/
	$(INSTALL_DATA) ./files/etc/config/obuspa $(1)/etc/config/
	$(INSTALL_DATA) ./files/etc/obuspa/roles.json $(1)/etc/obuspa/roles.json
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/85-obuspa $(1)/etc/hotplug.d/iface/
endef

$(eval $(call BuildPackage,obuspa))
