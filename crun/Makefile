include $(TOPDIR)/rules.mk

PKG_NAME:=crun
PKG_VERSION:=0.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/containers/crun.git
PKG_SOURCE_VERSION:=0e9229ae34caaebcb86f1fde18de3acaf18c6d9a

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/crun
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+yajl +argp-standalone +libcap +libseccomp
  TITLE:=A fast and low-memory footprint OCI Container Runtime fully written in C
endef

define Package/crun/description
  crun conforms to the OCI Container Runtime specifications
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
TARGET_LDFLAGS += -largp

MAKE_FLAGS := \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)"
	
define Build/Configure
	cd $(PKG_BUILD_DIR)/ && sh autogen.sh && ./configure
endef	

define Package/crun/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/bin/crun $(1)/usr/bin/
endef

$(eval $(call BuildPackage,crun))
