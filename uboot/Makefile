#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=u-boot
PKG_VERSION:=2016.08

PKG_SOURCE_PROTO:=git

ifdef CONFIG_TARGET_intel_mips
PKG_SOURCE_URL:=git@dev.iopsys.eu:intel/uboot.git
PKG_SOURCE_VERSION:=620a9176c6c0242900a7e69ac0e63d3acbfa4d35
else
PKG_SOURCE_URL:=https://dev.iopsys.eu/fork/uboot.git
PKG_SOURCE_VERSION:=3ef2ba866a99205496e0ce01935c89a1778d9b85
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

# u-boot for mips_intel do not build in parallel. 
#PKG_BUILD_PARALLEL:=1

# we currently do not use OpenWRT u_boot make files
#include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

# prevent openwrt source date to be used as build date by u-boot
unexport SOURCE_DATE_EPOCH


define uboot/Default
  TITLE:=
  CONFIG:=
  IMAGE:=
endef

UBOOT_IMG:=uboot.img

define uboot/ex400
  TITLE:=U-Boot for the ex400
  DEPENDS:=@TARGET_iopsys_ramips
  PKG_RELEASE:=6
endef

define uboot/sdx810_ap
  TITLE:=U-Boot for the sdx810_ap
  DEPENDS:=@TARGET_iopsys_ramips
  PKG_RELEASE:=6
endef

define uboot/grx500
  TITLE:=U-Boot for the grx
  UBOOT_IMG:=u-boot-nand.bin
  DEPENDS:=@TARGET_intel_mips
  PKG_RELEASE:=10
endef

# obsolete: no longer supported
define uboot/grx500_speedport_smart3
  TITLE:=U-Boot for the Speedport Smart3
  UBOOT_IMG:=u-boot-nand.bin
  DEPENDS:=@TARGET_intel_mips
  PKG_RELEASE:=7
endef

define uboot/grx500_norrland
  TITLE:=U-Boot for Norrland Board
  UBOOT_IMG:=u-boot-nand.bin
  DEPENDS:=@TARGET_intel_mips
  PKG_RELEASE:=11
endef

UBOOTS := \
	ex400 \
	sdx810_ap \
	grx500 \
	grx500_speedport_smart3 \
	grx500_norrland

define Package/uboot/template
define Package/uboot-$(1)
  SECTION:=boot
  CATEGORY:=Boot Loaders
  TITLE:=$(2)
  URL:=http://www.denx.de/wiki/U-Boot
  VARIANT:=$(1)
endef
endef

define BuildUBootPackage
	$(eval $(uboot/Default))
	$(eval $(uboot/$(1)))
	$(call Package/uboot/template,$(1),$(TITLE))
endef

ifdef BUILD_VARIANT
$(eval $(call uboot/$(BUILD_VARIANT)))
UBOOT_CONFIG:=$(if $(CONFIG),$(CONFIG),$(BUILD_VARIANT))
UBOOT_IMAGE:=$(if $(IMAGE),$(IMAGE),openwrt-$(BOARD)-$(BUILD_VARIANT)-u-boot.bin)
UBOOT_IOPSYS_VERSION:=$(PKG_RELEASE)
endif

define Build/Configure
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		$(UBOOT_CONFIG)_config

	$(SED) "s,CONFIG_INTENO_MAJOR=\"0\",CONFIG_INTENO_MAJOR=\"$(UBOOT_IOPSYS_VERSION)\"," $(PKG_BUILD_DIR)/.config

	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		oldconfig
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS)
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS) env
endef

# don't install /etc/init.d/uboot for intel-mips as it's not needed
define Package/uboot/install/default
	$(INSTALL_DIR) $$(1)/lib/upgrade
	$(CP) ./files/uboot-upgrade $$(1)/lib/upgrade/
	$(if $(CONFIG_TARGET_intel_mips), ,$(INSTALL_DIR) $$(1)/etc/init.d)
	$(if $(CONFIG_TARGET_intel_mips), ,$(CP) ./files/uboot $$(1)/etc/init.d/)

	$(INSTALL_DIR) $(BIN_DIR)/$(TARGET)
	$(INSTALL_DIR) $$(1)/boot
	$(CP) \
		$(PKG_BUILD_DIR)/$(UBOOT_IMG) \
		$(BIN_DIR)/$(TARGET)/uboot.img
	$(CP) \
		$(PKG_BUILD_DIR)/$(UBOOT_IMG) \
		$$(1)/boot/uboot.img

	$(INSTALL_DIR) $$(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/env/fw_printenv $$(1)/usr/sbin/
	ln -s /usr/sbin/fw_printenv $$(1)/usr/sbin/fw_setenv
endef

define Package/uboot/install/template
define Package/uboot-$(1)/install
	$(call Package/uboot/install/default,$(2))
endef
endef

$(foreach u,$(UBOOTS), \
	$(eval $(call Package/uboot/install/template,$(u),$(u))) \
)

$(foreach u,$(UBOOTS), \
	$(eval $(call BuildUBootPackage,$(u))) \
	$(eval $(call BuildPackage,uboot-$(u))) \
)
