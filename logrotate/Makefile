#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=logrotate
PKG_VERSION:=3.7.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.gz
PKG_SOURCE_URL:=http://ftp.de.debian.org/debian/pool/main/l/logrotate
PKG_MD5SUM:=552639142e163745f6bcd4f1f3816d8a
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/logrotate
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpopt
  TITLE:=rotates, compresses, and mails system logs
endef

define Build/Compile
	$(call Build/Compile/Default, \
		RPM_OPT_FLAGS="$(TARGET_CFLAGS) $(EXTRA_CPPFLAGS)" \
		LDFLAGS="$(EXTRA_LDFLAGS)" \
		logrotate \
	)
endef

define Package/logrotate/install	
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) ${PKG_BUILD_DIR}/logrotate $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(CP) ./files/logrotate.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/logrotate.d
endef

$(eval $(call BuildPackage,logrotate))
