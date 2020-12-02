#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=obuspa
PKG_VERSION:=3.0.0.2

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=6f4fe2f97a8813474adfc125d10fb122d66b0216
PKG_SOURCE_URL:=https://dev.iopsys.eu/fork/obuspa.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
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

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE

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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/obuspa $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/obuspa $(1)/etc/init.d/
	$(INSTALL_DATA) ./files/etc/config/obuspa $(1)/etc/config/
endef

$(eval $(call BuildPackage,obuspa))
