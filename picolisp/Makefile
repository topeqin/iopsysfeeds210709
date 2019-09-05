include $(TOPDIR)/rules.mk

PKG_NAME:=picolisp
PKG_VERSION=3.1.10
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/picoLisp
PKG_SOURCE:=picoLisp-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://software-lab.de/
PKG_MD5SUM:=ac19fd6ff4d05dd2b15ea00d1ed591e7

PKG_BUILD_DEPENDS+= +libopenssl +@OPENSSL_WITH_EC2M

PKG_LICENSE:=MIT-X11
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/picolisp
SECTION:=lang
CATEGORY:=Languages
TITLE:=PicoLisp interpreter
DEPENDS:= +libopenssl +@OPENSSL_WITH_EC2M
URL:=http://www.picolisp.org/
MAINTAINER:=Jeronimo Pellegrini <j_p@aleph0.info>
endef

define Package/picolisp/description
  Picolisp is yet another dialect of the Lisp language, specially written to be radically practical and simple.
endef

TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib
TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include

# A hack to make picoLisp's Makefile see the include path:
MAKE_FLAGS += C_INCLUDE_PATH+=$(STAGING_DIR)/usr/include/ 

define Package/picolisp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/picolisp/
	$(INSTALL_DIR) $(1)/usr/lib/picolisp/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/pil      $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/psh      $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/watchdog $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/picolisp $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/*.l        $(1)/usr/lib/picolisp/
	$(CP) $(PKG_BUILD_DIR)/lib/ht \
	   		$(PKG_BUILD_DIR)/lib/ext \
	   		$(PKG_BUILD_DIR)/lib/adm.l \
	   		$(PKG_BUILD_DIR)/lib/app.l \
	   		$(PKG_BUILD_DIR)/lib/boss.l \
	   		$(PKG_BUILD_DIR)/lib/btree.l \
	   		$(PKG_BUILD_DIR)/lib/conDbgc.l \
	   		$(PKG_BUILD_DIR)/lib/db.l \
		   	$(PKG_BUILD_DIR)/lib/debug.l \
	   		$(PKG_BUILD_DIR)/lib/edit.l \
			$(PKG_BUILD_DIR)/lib/ed.l \
			$(PKG_BUILD_DIR)/lib/form.l \
	   		$(PKG_BUILD_DIR)/lib/frac.l \
	   		$(PKG_BUILD_DIR)/lib/heartbeat.l \
	   		$(PKG_BUILD_DIR)/lib/http.l \
	   		$(PKG_BUILD_DIR)/lib/import.l \
	   		$(PKG_BUILD_DIR)/lib/led.l \
	   		$(PKG_BUILD_DIR)/lib/lint.l \
	   		$(PKG_BUILD_DIR)/lib/math32.l \
	   		$(PKG_BUILD_DIR)/lib/math64.l \
	   		$(PKG_BUILD_DIR)/lib/math.l \
	   		$(PKG_BUILD_DIR)/lib/misc.l \
	   		$(PKG_BUILD_DIR)/lib/pilog.l \
	   		$(PKG_BUILD_DIR)/lib/prof.l \
	   		$(PKG_BUILD_DIR)/lib/ps.l \
	   		$(PKG_BUILD_DIR)/lib/rsa.l \
	   		$(PKG_BUILD_DIR)/lib/scrape.l \
	   		$(PKG_BUILD_DIR)/lib/simul.l \
			$(PKG_BUILD_DIR)/lib/sq.l \
			$(PKG_BUILD_DIR)/lib/too.l \
			$(PKG_BUILD_DIR)/lib/xhtml.l \
	   		$(PKG_BUILD_DIR)/lib/xm.l \
	   		$(PKG_BUILD_DIR)/lib/xml.l \
	   		$(PKG_BUILD_DIR)/lib/xmlrpc.l	$(1)/usr/lib/picolisp/lib/
	touch $(1)/usr/lib/picolisp/lib/tags
	$(STRIP) $(1)/usr/bin/picolisp
endef

$(eval $(call BuildPackage,picolisp))
