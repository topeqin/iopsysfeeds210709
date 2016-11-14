include $(TOPDIR)/rules.mk

PKG_NAME:=libtrace
PKG_VERSION:=3.0.22
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/apietila/libtrace.git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/libtrace/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Libtrace library for packet trace processing
  URL:=http://research.wand.net.nz/software/libtrace.php
endef

define Package/libtrace
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Libtrace library for packet trace processing
  URL:=http://research.wand.net.nz/software/libtrace.php
  DEPENDS:=+libpcap +libpthread +zlib +libbz2 +liblzo +librt $(CXX_DEPENDS)
endef

define Package/libtrace/description
	Network trace processing library for trace processing. Supports multiple 
	input methods, including device capture, raw and gz-compressed 
	trace, and sockets.
endef

define Package/libtrace-tools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Libtrace tools for packet trace processing
  URL:=http://research.wand.net.nz/software/libtrace.php
  DEPENDS:=+libncurses +libtrace
endef

define Package/libtrace-tools/description
	Network trace processing tools for trace processing.
endef

CONFIGURE_ARGS += \
        --with-bzip2 \
        --with-zlib \
	--with-lzo \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtrace.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwandio.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpacketdump.{a,so*} $(1)/usr/lib/
endef

define Package/libtrace/install    
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libtrace.so.* $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libwandio.so.* $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libpacketdump.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/libpacketdump
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libpacketdump/*.so* $(1)/usr/lib/libpacketdump/
endef

define Package/libtrace-tools/install    
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{traceanon,tracediff,traceends,tracepktdump,tracereplay,tracereport,tracertstats,tracesplit,tracestats} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libtrace))
$(eval $(call BuildPackage,libtrace-tools))

