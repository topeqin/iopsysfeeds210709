#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=ltq-nand
PKG_VERSION:=1.0

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/merbanan/ltq-nand/archive/
#PKG_SOURCE_PROTO:=git
#PKG_SOURCE_URL:=https://github.com/merbanan/ltq-nand/releases/download/v$(PKG_VERSION)/
#PKG_SOURCE_URL:=https://github.com/merbanan/ltq-nand.git
#PKG_SOURCE_VERSION:=07b5b0331af6de4174dab2c02bf260ee9625452a

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/host-build.mk


define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)
endef

define Host/Install
	$(CP) \
		$(HOST_BUILD_DIR)/ltq-nand \
		$(STAGING_DIR_HOST)/bin/
endef

$(eval $(call HostBuild))

