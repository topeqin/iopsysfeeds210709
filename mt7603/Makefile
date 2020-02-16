# All rights reserved.
# See LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mtk7603e
PKG_VERSION:=4.1.2.0_20190222
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:mediatek/mt7603.git
PKG_SOURCE_VERSION:=4e94b2c3f45b7d5374ed988cdad925d5ca30b838
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz

MTK7603_CONFIG:=$(shell cat mtk7603e.config)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mtk7603e
  CATEGORY:=Mediatek drivers
  TITLE:=WiFi drivers
  #DEPENDS:= +wifi-profile
ifneq ($(CONFIG_MTK_FAST_NAT_SUPPORT), )
ifneq ($(CONFIG_NET_MEDIATEK_HNAT), )
  DEPENDS+=+kmod-mediatek_hnat
endif
endif
  FILES:=$(PKG_BUILD_DIR)/mt7603_wifi_ap/mt7603e.ko
  AUTOLOAD:=$(call AutoProbe, mt7603e)
  MENU:=1
endef

## check following
#CONFIG_MT7603E_HOTSPOT=y (depends on missing WAPP_SUPPORT)
#CONFIG_MT7603E_MBO_SUPPORT=y
#CONFIG_MT7603E_MAP_SUPPORT=y
#CONFIG_MT7603E_TXBF_SUPPORT=y (undef -DVHT_TXBF_SUPPORT)
#CONFIG_MT7603E_ACL_V2_SUPPORT=y (build error)
#CONFIG_MT7603E_DFS_SUPPORT=y (unnecessary)
#CONFIG_MT7603E_SINGLE_SKU_V2=y  (fix: get_single_sku_path())
#CONFIG_MT7603E_WDS_SUPPORT=y ( incomplete? )
#CONFIG_MT7603E_BTCOEX_CONCURRENT=y (undefined)

NOSTDINC_FLAGS := -DCONFIG_SECOND_IF_MT7615E -DCONFIG_FIRST_IF_MT7603E \
		-Wno-misleading-indentation


define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) V=1 \
		$(MTK7603_CONFIG) \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		SUBDIRS="$(PKG_BUILD_DIR)/mt7603_wifi_ap" \
		modules
endef

define KernelPackage/mtk7603e/install
	$(INSTALL_DIR) $(1)/etc/Wireless/RT2860
	$(CP) ./files/RT2860.dat $(1)/etc/Wireless/RT2860/RT2860.dat
endef

$(eval $(call KernelPackage,mtk7603e))
