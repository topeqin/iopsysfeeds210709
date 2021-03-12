# Copyright (C) 2019 iopsys
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=loop-detector
PKG_VERSION:=1.0

PKG_SOURCE_VERSION:=d0fb770eacd6691b98df138b60f5116e02f71a9b
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/loop-detector

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk


define Package/loop-detector
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=L2 Loop detector
  DEPENDS:= +libpcap +libuci +libpthread
endef

define Package/loop-detector/description
	L2 Loop detection package
endef

TARGET_CFLAGS += \
	-D_GNU_SOURCE

TARGET_LDFLAGS += \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += \
	--with-uci-include-path=$(STAGING_DIR)/usr/include \
	--with-libubox-include-path=$(STAGING_DIR)/usr/include \
	--with-libubus-include-path=$(STAGING_DIR)/usr/include

define Package/loop-detector/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/loop-detector $(1)/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(CP) ./files/loop_detection.init $(1)/etc/init.d/loop_detection
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/loop_detection.config $(1)/etc/config/loop_detection
endef

$(eval $(call BuildPackage,loop-detector))
