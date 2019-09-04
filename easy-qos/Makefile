#
# Copyright (C) 2019 iopsys Software Solutions AB
#
# This is free software, licensed under the GNU General Public License v2.
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=easy-qos
PKG_VERSION:=1.1
PKG_RELEASE:=0

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=none

include $(INCLUDE_DIR)/package.mk

define Package/easy-qos
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Easy QoS
endef

define Package/easy-qos/description
	This package contains Easy QoS utitie
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/easy-qos/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(CP) ./files/etc/config/easy_qos $(1)/etc/config/
ifeq ($(CONFIG_TARGET_intel_mips),y)
	$(CP) ./files/etc/init.d/easy_qos.classcfg $(1)/etc/init.d/easy_qos
else
	$(CP) ./files/etc/init.d/easy_qos.iptables $(1)/etc/init.d/easy_qos
endif
	$(CP) ./files/etc/uci-defaults/* $(1)/etc/uci-defaults/
	$(CP) ./files/etc/firewall.easyqos $(1)/etc/firewall.easyqos
endef

$(eval $(call BuildPackage,easy-qos))
