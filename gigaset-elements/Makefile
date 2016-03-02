include $(TOPDIR)/rules.mk

PKG_NAME:=gigaset-elements

PKG_VERSION:=2.1.2
# PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_GIGASET_ELEMENTS_SRC_URL ?= git@iopsys.inteno.se:gigaset-elements.git
PKG_GIGASET_ELEMENTS_VERSION ?= v$(PKG_VERSION)

PKG_SOURCE_URL:=$(PKG_GIGASET_ELEMENTS_SRC_URL)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_GIGASET_ELEMENTS_VERSION)


PKG_MAINTAINER:=Magier Marcin, Figlarek Piotr

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

######################################################

define Package/gigaset-elements
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libjson-c +libcurl
  TITLE:=Gigaset elements
endef

######################################################

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) all
endef



define Package/gigaset-elements/install
	$(CP) -r $(PKG_BUILD_DIR)/sysroot/* $(1)/
endef



define Package/gigaset-elements/preinst
#!/bin/sh
mkdir -p $${IPKG_INSTROOT}/usr/gigaset/data/cert
mkdir -p $${IPKG_INSTROOT}/usr/gigaset/data/fw
endef


define Package/gigaset-elements/postrm
#!/bin/sh
rm -rf $${IPKG_INSTROOT}/usr/gigaset/data
rm -rf /usr/share/gigaset
endef


######################################################

$(eval $(call BuildPackage,gigaset-elements))

