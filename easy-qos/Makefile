include $(TOPDIR)/rules.mk

PKG_NAME:=easy-qos
PKG_VERSION:=1.0
PKG_RELEASE:=0

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
	$(CP) ./files/etc/config/easy_qos $(1)/etc/config/
	$(CP) ./files/etc/init.d/easy_qos.iptables $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,easy-qos))
