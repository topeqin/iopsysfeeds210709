# All rights reserved.
# See LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mtk7615e
PKG_VERSION:=5.0.4.0_20190503

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:mediatek/mt7615.git
PKG_SOURCE_VERSION:=12c69fe1912113d16d17292bcee6415a8c9ab131
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz

MTK7615_CONFIG:=$(shell cat mtk7615e.config)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mtk7615e
  CATEGORY:=Mediatek drivers
  TITLE:=WiFi drivers
  #DEPENDS:= +wifi-profile
ifneq ($(CONFIG_MTK_FAST_NAT_SUPPORT), )
ifneq ($(CONFIG_NET_MEDIATEK_HNAT), )
  DEPENDS+=+kmod-mediatek_hnat
endif
endif
ifneq ($(CONFIG_MTK_WHNAT_SUPPORT), )
  FILES:=$(PKG_BUILD_DIR)/mt_wifi_ap/mt_wifi.ko \
	$(PKG_BUILD_DIR)/mt_wifi/embedded/plug_in/whnat/mt_whnat.ko
  AUTOLOAD:=$(call AutoProbe,mt_wifi mt_whnat)
else
  FILES:=$(PKG_BUILD_DIR)/mt_wifi_ap/mt_wifi.ko
  AUTOLOAD:=$(call AutoProbe,mt_wifi)
endif
  MENU:=1
endef

NOSTDINC_FLAGS := -DCONFIG_SECOND_IF_MT7615E -DCONFIG_FIRST_IF_MT7603E \
		-Wno-misleading-indentation


define Build/Compile
	$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) V=1 \
		$(MTK7615_CONFIG) \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		SUBDIRS="$(PKG_BUILD_DIR)/mt_wifi_ap" \
		modules
endef

define KernelPackage/mtk7615e/install
	$(INSTALL_DIR) $(1)/etc/wireless
	$(CP) ./files/l1profile.dat $(1)/etc/wireless
	$(INSTALL_DIR) $(1)/etc/Wireless/iNIC
	$(CP) ./files/iNIC_ap.dat $(1)/etc/Wireless/iNIC/iNIC_ap.dat
endef

$(eval $(call KernelPackage,mtk7615e))
