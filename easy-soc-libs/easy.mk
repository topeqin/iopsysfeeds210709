

define Package/libeasy
  $(call Package/easy-soc-libs)
  TITLE:= Common helper functions library (libeasy)
  DEPENDS+=+libnl +libnl-route
endef

define Build/InstallDev/libeasy
	$(INSTALL_DIR) $(1)/usr/include/easy
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libeasy/easy.h $(1)/usr/include/easy/
	$(CP) $(PKG_BUILD_DIR)/libeasy/event.h $(1)/usr/include/easy/
	$(CP) $(PKG_BUILD_DIR)/libeasy/utils.h $(1)/usr/include/easy/
	$(CP) $(PKG_BUILD_DIR)/libeasy/if_utils.h $(1)/usr/include/easy/
	$(CP) $(PKG_BUILD_DIR)/libeasy/debug.h $(1)/usr/include/easy/
	$(CP) $(PKG_BUILD_DIR)/libeasy/libeasy*.so* $(1)/usr/lib/
endef

define Package/libeasy/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libeasy/libeasy*.so* $(1)/usr/lib/
endef

