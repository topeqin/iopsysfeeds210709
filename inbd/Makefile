#
# Copyright (C) 2016 iopsys
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=inbd
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=665a72a6bb2b5ea5a17ad6248957fe35525b3782
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/inbd

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
	TITLE:=iopsys Netlink Bridge Daemon
	URL:=
	DEPENDS:=+libuci +libubus +libblobmsg-json +libnl-genl
endef

define Package/inbd/description
	Application handling netlink messages from kernel and sending them out on ubus.
endef

define Package/inbd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/inbd $(1)/usr/bin/
	cp $(PKG_BUILD_DIR)/files/etc/init.d/inbd $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,inbd))
