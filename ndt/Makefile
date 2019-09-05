#
# This is free software, See /COPYRIGHT for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ndt
PKG_VERSION:=3.6.4
PKG_RELEASE:=3

PKG_BUILD_DIR:=${BUILD_DIR}/ndt-$(PKG_VERSION)
PKG_SOURCE:=ndt-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://software.internet2.edu/sources/ndt

PKG_LICENSE:=NONSTANDARD
PKG_LICENSE_FILES:=COPYRIGHT

include $(INCLUDE_DIR)/package.mk

define Package/ndt
	CATEGORY:=Utilities
	DEPENDS:=+libpthread +zlib
	TITLE:=Network Testing Tool
endef

define Build/Compile/Default
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/ndt/install
	$(INSTALL_DIR) $(1)/sbin
	$(CP) $(PKG_BUILD_DIR)/src/web100clt $(1)/sbin/
endef

$(eval $(call BuildPackage,ndt))

