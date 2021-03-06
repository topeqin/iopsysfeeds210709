#
# Copyright (C) 2019 iopsys
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=peripheral_manager
PKG_VERSION:=1.0.6
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=785166a9861a119623556163179915727896156b
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/peripheral-manager

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

# support parallel build
PKG_BUILD_PARALLEL:=1

# run install target when cross compiling. basically, make install DESTDIR=$(PKG_INSTALL_DIR)
# this way we don't need to pick out the resulting files from the build dir.
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/peripheral_manager
	CATEGORY:=Utilities
	TITLE:=Application deamon for handling of peripheral
	URL:=
	DEPENDS:=+libuci +libubus +libblobmsg-json
endef

define Package/peripheral_manager/description
	Application handling peripheral
endef

CMAKE_OPTIONS +=  \
		-DCMAKE_BUILD_TYPE:String="Release" \

define Package/peripheral_manager/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/peripheral_manager $(1)/sbin/
#	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gpio_test $(1)/sbin/
endef

$(eval $(call BuildPackage,peripheral_manager))
