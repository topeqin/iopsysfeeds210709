#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libcgroup
PKG_VERSION:=0.41
PKG_RELEASE:=1

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_VERSION:=2186c97f60df7efe86ddadd5e3d9d36dd4923b98

PKG_SOURCE_URL:=git://git.code.sf.net/p/libcg/libcg
PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)+git$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

#PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

# run install target when cross compiling. basically, make install DESTDIR=$(PKG_INSTALL_DIR)
# this way we don't need to pick out the resulting files from the build dir.
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libcgroup
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpthread
  TITLE:=Control group configuration library
  URL:=https://sourceforge.net/p/libcg/
endef

define Package/libcgroup/description
  Control groups, a new kernel feature in Linux 2.6.24 provides a file system
  interface to manipulate and control the details on task grouping including
  creation of new task groups (control groups), permission handling and task
  assignment.
endef

define Package/libcgroup-daemon
  SECTION:=base
  CATEGORY:=Base system
  DEPENDS:=+libcgroup +librt
  TITLE:=Control group management daemon
  URL:=https://sourceforge.net/p/libcg/
endef

define Package/libcgroup-utils
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libcgroup
  TITLE:=Control group configuration utilities
  URL:=https://sourceforge.net/p/libcg/
endef

#define Package/libcgroup/conffiles
#	/etc/config/cgroups
#endef

CONFIGURE_ARGS += \
		--disable-bindings \
		--disable-pam \
		--enable-static \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libcgroup
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/libcgroup/*.h $(1)/usr/include/libcgroup/

	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libcgroup.* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libcgroup.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libcgroup/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libcgroup.so* $(1)/usr/lib/
endef

define Package/libcgroup-daemon/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin

	# move to its own package?
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/cgroups.config $(1)/etc/config/cgroups
	$(INSTALL_BIN) ./files/cgroups.init $(1)/etc/init.d/cgroups
endef

define Package/libcgroup-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
endef

$(eval $(call BuildPackage,libcgroup))
$(eval $(call BuildPackage,libcgroup-daemon))
$(eval $(call BuildPackage,libcgroup-utils))
