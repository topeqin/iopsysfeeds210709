
include $(TOPDIR)/rules.mk

PKG_NAME:=bashdb
PKG_VERSION:=4.4-0.92
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
#PKG_SOURCE_URL:=http://sourceforge.net/projects/bashdb/files/bashdb/$(PKG_VERSION)
PKG_SOURCE_URL:=@SF/bashdb/
PKG_MD5SUM:=b72c17870bfab2fd791b1f6de4d79f9e
#PKG_CAT:=zcat
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Bash script debugging utility.
  URL:=http://sourceforge.net/projects/bashdb/
endef

define Package/$(PKG_NAME)/description
  Bash script debugging utility.
endef

define Build/Compile
        $(MAKE) -C $(PKG_BUILD_DIR) \
                $(TARGET_CONFIGURE_OPTS) \
                CFLAGS="$(TARGET_CFLAGS) -DLINUX $(TARGET_CPPFLAGS) \
                        -I./src" \
                LIBS="$(TARGET_LDFLAGS)" \
                DESTDIR="$(PKG_INSTALL_DIR)"
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bashdb $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/share
	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/*.sh  $(1)/usr/share/$(PKG_NAME)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/*.inc  $(1)/usr/share/$(PKG_NAME)/

	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)/init
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/init/*.sh  $(1)/usr/share/$(PKG_NAME)/init/

	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)/command
	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)/command/show_sub
	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)/command/set_sub
	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)/command/info_sub
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/command/*.sh $(1)/usr/share/$(PKG_NAME)/command/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/command/show_sub/*.sh $(1)/usr/share/$(PKG_NAME)/command/show_sub/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/command/set_sub/*.sh $(1)/usr/share/$(PKG_NAME)/command/set_sub/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/command/info_sub/*.sh $(1)/usr/share/$(PKG_NAME)/command/info_sub/

	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lib/*.sh $(1)/usr/share/$(PKG_NAME)/lib/
endef

$(eval $(call BuildPackage,bashdb))
