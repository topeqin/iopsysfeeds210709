#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=inotify-tools
PKG_VERSION:=3.14
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=1df9af4d6cd0f4af4b1b19254bcf056aed4ae395
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rvoicilas/inotify-tools.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

# support parallel build
PKG_BUILD_PARALLEL:=1

#re create configure scripts if not present.
PKG_FIXUP:=autoreconf

# run install target when cross compiling. basically, make install DESTDIR=$(PKG_INSTALL_DIR)
# this way we don't need to pick out the resulting files from the build dir.
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/inotify-tools
	CATEGORY:=Utilities
	TITLE:=Tools to trace filesystem events.
	URL:=
endef

define Package/inotify-tools/description
	Tools to trace filesystem events.
endef

define Package/inotify-tools/install
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) ./files/* $(1)/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libinotifytools.so.0.4.1 $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libinotifytools.so.0 $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libinotifytools.so $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/inotifywait $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/inotifywatch $(1)/usr/bin/
endef

$(eval $(call BuildPackage,inotify-tools))
