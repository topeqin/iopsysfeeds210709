
define Package/libwifi
  $(call Package/easy-soc-libs)
  TITLE:= WiFi library (libwifi)
  DEPENDS+=+libnl +libnl-route +libeasy +TARGET_iopsys_brcm63xx_arm:bcmkernel +PACKAGE_libwpa_client:libwpa_client

endef

define Package/libwifi/config
  if PACKAGE_libdsl
	  config LIBWIFI_DEBUG
		depends on PACKAGE_libwifi
		bool "Enable wifi debugging"
		default n

  endif
endef

define Build/InstallDev/libwifi
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifi/wifi.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libwifi/libwifi*.so* $(1)/usr/lib/
endef

define Package/libwifi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwifi/libwifi*.so* $(1)/usr/lib/
endef

