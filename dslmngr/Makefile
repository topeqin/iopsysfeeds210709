#
# Copyright (C) 2018 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dslmngr
PKG_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=4dca0fd11b75debe3661a5a399d198ebef6fcb0e
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/dslmngr.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/dslmngr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=XDSL status and configration utility
  DEPENDS:=+libdsl +libuci +libubox +ubus +libpthread +libnl-genl
endef

define Package/dslmngr/description
 This package can be used to configure and provide status about
 the XDSL subsystem through UBUS.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/libnl3 \
	-D_GNU_SOURCE

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	FPIC="$(FPIC)"

define Build/Compile
	+$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
endef

define Package/dslmngr/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dslmngr $(1)/sbin/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,dslmngr))
