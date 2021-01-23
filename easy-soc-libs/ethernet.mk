
define Package/libethernet
  $(call Package/easy-soc-libs)
  TITLE:= Ethernet library (libethernet)
  DEPENDS+=+libnl +libnl-route +libeasy +TARGET_iopsys_ramips:swconfig
endef

define Package/libethernet/config
  config LIBETHERNET_DEBUG
	depends on PACKAGE_libethernet
	bool "Enable ethernet debugging"
	default n

endef

define Build/InstallDev/libethernet
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libethernet/ethernet.h $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libethernet/libethernet.so $(1)/usr/lib/
endef

define Package/libethernet/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libethernet/libethernet.so* $(1)/usr/lib/
endef

