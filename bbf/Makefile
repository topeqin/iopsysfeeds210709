#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libbbfdm
PKG_VERSION:=1.0-2019-11-05
PKG_FIXUP:=autoreconf
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/bbf.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=8b6a24669f6a0d63ac1c706fbe607eddd6446bce
PKG_RELEASE=$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/libbbfdm
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library for broadband-forum data model
  DEPENDS:=+libuci +libubox +libubus +libblobmsg-json +libjson-c +libtrace
endef

define Package/libbbfdm/config
	source "$(SOURCE)/Config_bbfdm.in"
endef

define Package/libbbfdm/description
 Test description will update later.
endef

TARGET_CFLAGS += -DCUSTOM_PREFIX=\\\"$(CONFIG_LIBBBFDM_VENDOR_PREFIX)\\\"

TARGET_CFLAGS += \
	-D_GNU_SOURCE -D_AADJ

ifeq ($(CONFIG_BBF_TR181),y)
CONFIGURE_ARGS += \
	--enable-tr181
endif

ifeq ($(CONFIG_BBF_TR104),y)
CONFIGURE_ARGS += \
	--enable-tr104
endif

ifeq ($(CONFIG_BBF_TR143),y)
CONFIGURE_ARGS += \
	--enable-tr143
endif

ifeq ($(CONFIG_BBF_TR157),y)
CONFIGURE_ARGS += \
	--enable-tr157
endif

ifeq ($(CONFIG_BBF_TR064),y)
CONFIGURE_ARGS += \
	--enable-tr064
endif

define Package/libbbfdm/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbfdm.so* $(1)/lib/
	$(INSTALL_DIR) $(1)/etc/bbfdm
	$(INSTALL_DIR) $(1)/etc/bbfdm/json
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/dmmap $(1)/etc/bbfdm
	$(INSTALL_DIR) $(1)/usr/share/bbfdm
	$(CP) $(PKG_BUILD_DIR)/scripts/functions $(1)/usr/share/bbfdm
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/libbbfdm
	$(CP) $(PKG_BUILD_DIR)/*.h $(1)/usr/include/libbbfdm/
	$(CP) $(PKG_BUILD_DIR)/dmtree/tr181/*.h $(1)/usr/include/libbbfdm/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/bin/.libs/libbbfdm.{a,so*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbbfdm))
