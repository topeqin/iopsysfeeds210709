# All rights reserved.
# See LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=easy-soc-events
PKG_VERSION:=1.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/easy-soc-events.git
PKG_SOURCE_VERSION:=5c582b0165b574dc94e4865f82e0bb91fa561754
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/easy-soc-events-$(PKG_VERSION)
PKG_MAINTAINER:=Anjan Chanda <anjan.chanda@iopsys.eu>

include $(INCLUDE_DIR)/package.mk

-include $(TOPDIR)/.config

ifneq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),)
  LINUX_DIR=$(BUILD_DIR)/bcmkernel/bcm963xx/kernel/linux-4.1
  LINUX_VERSION := 4.1.52
  LINUXINCLUDE=-Iarch/$(LINUX_KARCH)/mach-bcm963xx/include
  BCM_BS_PROFILE := $(patsubst "%",%,$(CONFIG_BCM_KERNEL_PROFILE))
  FS_DIR := $(BUILD_DIR)/bcmkernel/bcm963xx/targets/$(BCM_BS_PROFILE)/fs
  MODULES_SUBDIR:=lib/modules/$(LINUX_VERSION)/extra
  TARGET_MODULES_DIR:=/$(MODULES_SUBDIR)
endif


define KernelPackage/easy-soc-events/default
  SUBMENU:=Other modules
endef

define KernelPackage/easy-soc-events
  $(KernelPackage/easy-soc-events/default)
  TITLE:=Helper module for netlink event notification
  FILES:=$(PKG_BUILD_DIR)/easyevent.ko
  AUTOLOAD:=$(call AutoLoad,11,easyevent)
endef

define KernelPackage/easy-soc-events-test
  $(KernelPackage/easy-soc-events/default)
  TITLE:=Test module for event notification through easyevent
  DEPENDS+=+kmod-easy-soc-events
  FILES+=$(PKG_BUILD_DIR)/test/testevent.ko
endef


define KernelPackage/easy-soc-events/description
  This is a helper module to generate and pass netlink events from
  kernel to user applications.
endef

#NOSTDINC_FLAGS :=

ifdef CONFIG_PACKAGE_kmod-easy-soc-events
  PKG_MAKE_FLAGS += CONFIG_EASYEVENT=y
endif

LINUXINCLUDE += \
		-I$(LINUX_DIR)/include -I$(LINUX_DIR)/include/$(LINUX_UAPI_DIR) \
		-Iarch/$(LINUX_KARCH)/include \
		-Iarch/$(LINUX_KARCH)/include/generated \
		-Iarch/$(LINUX_KARCH)/include/generated/$(LINUX_UAPI_DIR) \
		-I$(LINUX_DIR)/include/generated/uapi \
		-Iarch/$(LINUX_KARCH)/include/$(LINUX_UAPI_DIR) \
		-include ./include/linux/kconfig.h


define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) V=1 \
		$(PKG_MAKE_FLAGS) \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		LINUXINCLUDE="$(LINUXINCLUDE)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		modules
endef


ifneq ($(CONFIG_TARGET_iopsys_brcm63xx_arm),)
define KernelPackage/easy-soc-events/install-extra
	cp $(PKG_BUILD_DIR)/easyevent.ko $(FS_DIR)/lib/modules/$(LINUX_VERSION)/extra
endef
endif

define KernelPackage/easy-soc-events/install
	$(call KernelPackage/easy-soc-events/install-extra)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	#$(INSTALL_DIR) $(STAGING_DIR)/usr/include/linux
	#$(CP) $(PKG_BUILD_DIR)/easysoc-event.h $(STAGING_DIR)/usr/include/linux/
	#$(CP) $(PKG_BUILD_DIR)/easysoc-event.h $(LINUX_DIR)/include/linux/
	$(CP) $(PKG_BUILD_DIR)/easyevent.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/wifievent.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/easyevent.h $(LINUX_DIR)/include/generated/uapi
	$(CP) $(PKG_BUILD_DIR)/wifievent.h $(LINUX_DIR)/include/generated/uapi
endef

$(eval $(call KernelPackage,easy-soc-events-test))
$(eval $(call KernelPackage,easy-soc-events))
