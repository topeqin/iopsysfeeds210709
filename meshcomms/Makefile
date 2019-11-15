#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=meshcomms
PKG_VERSION:=1.0.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=72048b609104a5479ac2cdae21d5d1f733fd2bc3
PKG_SOURCE_URL:=https://dev.iopsys.eu/fork/meshcomms.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=BSD2+Patent
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/meshcomms
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Mesh agent
  DEPENDS:=+libpcap +libopenssl +libubox +libubus +libblobmsg-json
endef

define Package/meshcomms/description
 meshComms is an open source implementation of IEEE 1905.1a that is an output
 of the Broadband Forum Open Broadband - Multi Access Point (OB-MAP) project.
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include \
	-D_GNU_SOURCE
#        -DDO_NOT_ACCEPT_UNAUTHENTICATED_COMMANDS

#define Build/Prepare
#        $(CP) -rf ./meshcomms/* $(PKG_BUILD_DIR)/
#endef

define Package/meshcomms/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(STAGING_DIR)/usr/lib
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/meshcomms
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/meshcomms/common
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/meshcomms/bbf
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/meshcomms/al
	$(INSTALL_DIR) $(STAGING_DIR)/usr/include/meshcomms/factory
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/meshcomms.conf $(1)/etc/config/meshcomms
	$(INSTALL_BIN) ./files/meshcomms.init $(1)/etc/init.d/meshcomms
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/al_entity $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/libmeshcomms.so $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/output/libmeshcomms.so $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/include/meshcomms.h $(STAGING_DIR)/usr/include/meshcomms/
	$(CP) $(PKG_BUILD_DIR)/src/common/interfaces/*.h $(STAGING_DIR)/usr/include/meshcomms/
	$(CP) $(PKG_BUILD_DIR)/src/factory/interfaces/*.h $(STAGING_DIR)/usr/include/meshcomms/
	$(CP) $(PKG_BUILD_DIR)/src/factory/interfaces/extensions/bbf/*.h $(STAGING_DIR)/usr/include/meshcomms/
	$(CP) $(PKG_BUILD_DIR)/src/al/internal_interfaces/*.h $(STAGING_DIR)/usr/include/meshcomms/
endef

$(eval $(call BuildPackage,meshcomms))
