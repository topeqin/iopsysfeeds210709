#
# Copyright (C) 2019 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icgroupd
PKG_VERSION:=1.0
PKG_RELEASE:=0

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=Inteno Broadband AB

include $(INCLUDE_DIR)/package.mk

define Package/icgroupd
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Inteno cgroup daemon
  DEPENDS:=+uci +busybox
endef

define Package/icgroupd/description
	This package contains Intenos cgroup daemon and associated
	configuration and startup scripts.
endef

define Build/Compile
	true
endef

define Package/icgroupd/install
	$(INSTALL_DIR) $(1)/sbin $(1)/etc/init.d $(1)/etc/config

	$(INSTALL_CONF) ./files/cgroups.config $(1)/etc/config/cgroups
	$(INSTALL_BIN) ./files/cgroups.init $(1)/etc/init.d/cgroups
	$(INSTALL_BIN) ./files/cgroupd $(1)/sbin/
endef

$(eval $(call BuildPackage,icgroupd))

