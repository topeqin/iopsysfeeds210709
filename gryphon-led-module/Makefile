# Copyright (c) 2017 Genexis B.V.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=gryphon-led-kernel-module
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  SUBMENU:=Genexis
  TITLE:=LED driver for Gryphon
  FILES:=$(PKG_BUILD_DIR)/$(PKG_NAME).$(LINUX_KMOD_SUFFIX)
  KCONFIG:=CONFIG_PACKAGE_kmod-gryphon-led-kernel-module=y
  AUTOLOAD:=$(call AutoLoad,60,$(PKG_NAME))
  PKG_LICENSE:=Genexis
  PKG_LICENSE_URL:=
endef

define KernelPackage/$(PKG_NAME)/description
  This package contains the LED driver for Gryphon devices.
endef

EXTRA_KCONFIG:= CONFIG_RGB_LED=m

MODULE_INCLUDE=-I$(PKG_BUILD_DIR)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/kdevlinks/
	$(CP) -s `pwd`/src/* $(PKG_BUILD_DIR)/kdevlinks/
	$(CP) src/* $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="-DKERNEL_MODULE $(BUILDFLAGS) -I$(LINUX_DIR)/include -include generated/autoconf.h $(MODULE_INCLUDE)" \
		modules
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
