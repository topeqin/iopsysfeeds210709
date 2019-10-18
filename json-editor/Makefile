#
# Copyright (C) 2019 IOPSYS
#

include $(TOPDIR)/rules.mk

PKG_NAME:=json-editor
PKG_RELEASE:=1.0.0

PKG_SOURCE_VERSION:=44b32937a062ec4ffc9f7355841dc94ab6efa50f
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@dev.iopsys.eu:iopsys/json-editor.git

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/json-editor
  SECTION:=base
  CATEGORY:=Libraries
  DEPENDS:=+libjson-c +libblobmsg_json
  TITLE:=JSON-editor
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/src/json-editor.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libjson-editor.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,json-editor))
