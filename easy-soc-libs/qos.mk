
define Package/libqos
  $(call Package/easy-soc-libs)
  TITLE:= QoS library (libqos)
  DEPENDS+=+libnl +libnl-route +libeasy
endef

define Package/libqos/config
  config LIBQOS_DEBUG
	depends on PACKAGE_libqos
	bool "Enable qos debugging"
	default n

endef

define Build/InstallDev/libqos
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	#$(CP) $(PKG_BUILD_DIR)/libqos/qos.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libqos/libqos.so $(1)/usr/lib/
endef

define Package/libqos/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libqos/libqos*.so* $(1)/usr/lib/
endef

