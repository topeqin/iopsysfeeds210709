#
# Copyright (C) 2021 IOPSYS
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=urlfilter
PKG_VERSION:=1.1.1

LOCAL_DEV:=0
ifneq ($(LOCAL_DEV),1)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=a2fca29140673d058eb0bfb2b3b3c9e61d7f301f
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/urlfilter.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/urlfilter
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=URL filter
  DEPENDS:=+libuci +libnetfilter-queue +libnfnetlink +iptables-mod-nfqueue +libpthread +libubox +ubus +conntrack
endef

define Package/urlfilter/description
	Enables filtering of packets on the basis of URL and source MAC address.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
        -D_GNU_SOURCE

ifeq ($(LOCAL_DEV),1)
define Build/Prepare
        $(CP) -rf ./urlfilter/* $(PKG_BUILD_DIR)/
endef
endif

define Package/urlfilter/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/urlfilter $(1)/usr/sbin
endef

$(eval $(call BuildPackage,urlfilter))
