#
# Copyright (C) 2019 iopsys
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iop
PKG_VERSION:=1.0
PKG_RELEASE:=0
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/iop
  SECTION:=net
  CATEGORY:=Network
  TITLE:=iop utilities
endef

define Package/iop/description
	This package contains iopsysWrt SDK utilities
endef

define Build/Compile
	true
endef

define Package/iop/install
	true
endef

$(eval $(call BuildPackage,iop))
