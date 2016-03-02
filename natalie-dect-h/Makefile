#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=natalie-dect-h
PKG_VERSION:=12.13

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL:=http://public.inteno.se:/natalie-dect-h
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=d425e2183044ea146e140834f1c0410ae184a168
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/image.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/natalie-dect-h
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Dect stack headers
  URL:=
endef

define Package/natalie-dect-h/description
	Kernel dect driver headers
endef


define Package/natalie-dect-h/install
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/natalie-dect
	$(CP) -r $(PKG_BUILD_DIR)/SrcHeaders/* $(STAGING_DIR)/usr/include/natalie-dect/
endef

$(eval $(call BuildPackage,natalie-dect-h))
