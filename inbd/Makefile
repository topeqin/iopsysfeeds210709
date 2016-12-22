#
# Copyright (C) 2016 Inteno
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=inbd
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=51f7502ad1ce347af8a09531a782b87e94484599
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se/inbd

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

# support parallel build
PKG_BUILD_PARALLEL:=1

#re create configure scripts if not present.
PKG_FIXUP:=autoreconf

# run install target when cross compiling. basically, make install DESTDIR=$(PKG_INSTALL_DIR)
# this way we don't need to pick out the resulting files from the build dir.
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/inbd
	CATEGORY:=Utilities
	TITLE:=Inteno Netlink Bridge Daemon
	URL:=
	DEPENDS:=+libuci +libubus +libblobmsg-json +libnl-genl
endef

define Package/inbd/description
	Application handling netlink messages from kernel and sending them out on ubus.
endef

define Package/inbd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/inbd $(1)/usr/bin/
endef

$(eval $(call BuildPackage,inbd))
