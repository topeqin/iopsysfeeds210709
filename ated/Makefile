#
# Copyright (C) 2016 inteno
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ated
PKG_VERSION:=1.2.2
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=f614cba983d827d5185c60a6a5a35530621d44d2
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@private.inteno.se:ated

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

# support parallel build
#PKG_BUILD_PARALLEL:=1

#re create configure scripts if not present.
#PKG_FIXUP:=autoreconf

# run install target when cross compiling. basically, make install DESTDIR=$(PKG_INSTALL_DIR)
# this way we don't need to pick out the resulting files from the build dir.
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ated
	CATEGORY:=Utilities
	TITLE:=Daemon for handling wifi calibration
	URL:=
	DEPENDS:= libc
endef

define Package/ated/description
	Daemon for handling wifi calibration
endef

#TARGET_CFLAGS += -I$(LINUX_DIR)/include -I$(LINUX_DIR)/arch/mips/include

MAKE_FLAGS += \
	v=2 \
	m=3


#TARGET_CPPFLAGS := \
#	-I$(STAGING_DIR)/usr/include/bcm963xx/shared/opensource/include/bcm963xx \
#	-I$(STAGING_DIR)/usr/include/bcm963xx/bcmdrivers/opensource/include/bcm963xx \
#	$(TARGET_CPPFLAGS)

# we donot wwant to have any install.
define Build/Install/Default
endef

define Package/ated/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ated $(1)/sbin/
endef

$(eval $(call BuildPackage,ated))
