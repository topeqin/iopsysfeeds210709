
define Package/libdsl
  $(call Package/easy-soc-libs)
  TITLE:= XDSL library (libdsl)
  DEPENDS+=+TARGET_intel_mips:dsl-cpe-api-vrx \
	   +TARGET_intel_mips:dsl-cpe-fapi \
	   +TARGET_intel_mips:kmod-ppa-drv
endef

define Package/libdsl/config
  if PACKAGE_libdsl
	  config LIBDSL_DEBUG
		depends on PACKAGE_libdsl
		bool "Enable dsl debugging"
		default n

	  config LIBDSL_TEST
		depends on PACKAGE_libdsl
		bool "Enable dsl test program"
		default n

  endif
endef

define Build/InstallDev/libdsl
	$(INSTALL_DIR) $(1)/usr/include/xdsl
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libdsl/xdsl.h $(1)/usr/include/xdsl
	$(CP) $(PKG_BUILD_DIR)/libdsl/xtm.h $(1)/usr/include/xdsl
	$(CP) $(PKG_BUILD_DIR)/libdsl/common.h $(1)/usr/include/xdsl
	$(CP) $(PKG_BUILD_DIR)/libdsl/libdsl.so* $(1)/usr/lib/
endef

ifeq ($(CONFIG_LIBDSL_TEST),y)
define Build/Compile/libdsl
	$(MAKE) -C "$(PKG_BUILD_DIR)/libdsl/test" $(MAKE_FLAGS)
endef
endif

define Package/libdsl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/libdsl/libdsl.so* $(1)/usr/lib/
ifeq ($(CONFIG_LIBDSL_TEST),y)
	$(CP) $(PKG_BUILD_DIR)/libdsl/test/libdsl_test $(1)/usr/bin/
endif
endef
