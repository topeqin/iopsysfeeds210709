#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=fatrace
PKG_VERSION:=0.12
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=98af6019a4a1b478a6fa35f74528cb3cd404ae40
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.launchpad.net/fatrace

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

# support parallel build
#PKG_BUILD_PARALLEL:=1

#re create configure scripts if not present.
#PKG_FIXUP:=autoreconf

# run install target when cross compiling. basically, make install DESTDIR=$(PKG_INSTALL_DIR)
# this way we don't need to pick out the resulting files from the build dir.
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS := CONFIG_KERNEL_FANOTIFY

include $(INCLUDE_DIR)/package.mk

define Package/fatrace
	CATEGORY:=Utilities
	TITLE:=Report system wide file access events
	URL:=
	DEPENDS	:= +@KERNEL_FANOTIFY
endef

define Package/fatrace/description
	Report system wide file access events.
endef

MAKE_INSTALL_FLAGS += PREFIX="/" 

define Package/fatrace/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/fatrace $(1)/sbin/
#	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fatrace))


