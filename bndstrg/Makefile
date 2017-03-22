include $(TOPDIR)/rules.mk

PKG_NAME:=bndstrg
PKG_VERSION:=1.0
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE:=bndstrg-1.0.tar.gz
PKG_SOURCE_URL:=http://192.168.1.130/
PKG_MD5SUM:=17dc17dff9eefd0c41a54cc42ce972da

PKG_BUILD_DIR:=$(BUILD_DIR)/bndstrg-$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=bndstrg-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk



define Package/bndstrg
  SECTION:=base
  CATEGORY:=Network
  TITLE:=Band steering daemon for Mediatek
endef

define Package/bndstrg/description
 Band steering for Mediatek
 Band steering for Mediatek
 Band steering for Mediatek
endef

#define Build/Compile
#endef

define Build/Configure
  #$(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

define Package/bndstrg/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bndstrg $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,bndstrg))
