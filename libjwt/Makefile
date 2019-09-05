
# Copyright (C) 2018 Iopsys
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libjwt
PKG_VERSION:=1.0.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=866607c7741421c8ac99876e7201eb32d9af1b92
PKG_SOURCE_URL:=https://github.com/benmcollins/libjwt.git

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)_$(PKG_SOURCE_VERSION).tar.xz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

PKG_LICENSE:=LGPLv3
PKG_LICENSE_FILES:=COPYING
include $(INCLUDE_DIR)/package.mk

define Package/libjwt
  CATEGORY:=Libraries
  DEPENDS:=+libopenssl +jansson
  TITLE:= libjwt
endef


#TARGET_CFLAGS += \
#	-I$(STAGING_DIR)/usr/include
#	-I$(STAGING_DIR)/usr/include/libnl3

#MAKE_FLAGS += \
#	CFLAGS="$(TARGET_CFLAGS)" \
#	LDFLAGS="$(TARGET_LDFLAGS)" \
#	FPIC="$(FPIC)" \
#	PLATFORM="$(TARGET_PLATFORM)" \
#	subdirs="$(subdirs)"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/include/jwt.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libjwt/.libs/libjwt.so* $(1)/usr/lib/
endef

define Package/libjwt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libjwt/.libs/libjwt.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libjwt))
