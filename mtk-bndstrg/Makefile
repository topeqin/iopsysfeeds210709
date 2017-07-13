include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mtk-bndstrg
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=dc542ed2f07ee0ff6966d498665c1d4ea571f06e
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://public.inteno.se:/mtk-bndstrg

PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/mtk-bndstrg
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpthread +librt
  TITLE:=Band steering daemon for Mediatek
endef

define Package/mtk-bndstrg/description
 Band steering for Mediatek
endef

#define Build/Compile
#endef

define Build/Configure
  #$(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

define Package/mtk-bndstrg/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bndstrg $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,mtk-bndstrg))
