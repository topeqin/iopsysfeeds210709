#
# Copyright (C) 2014 Inteno
#

include $(TOPDIR)/rules.mk

PKG_NAME:=voice-client
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_iopsys_brcm63xx_mips),y)
VOICE_LIB:=broadcom.sh
else ifeq ($(CONFIG_TARGET_iopsys_linksys),y)
VOICE_LIB:=broadcom.sh
else ifeq ($(CONFIG_TARGET_intel_mips),y)
VOICE_LIB:=intel.sh
else ifeq ($(CONFIG_TARGET_iopsys_ramips),y)
VOICE_LIB:=broadcom.sh
else
$(info (UNEXPECTED CONFIG TARGET))
VOICE_LIB:=broadcom.sh
endif

define Package/voice-client
  SUBMENU:=Telephony
  SECTION:=net
  CATEGORY:=Network
  TITLE:=voice-client
  DEPENDS:=+asterisk13
endef

define Package/voice-client/description
	voice-client
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/voice-client/install
	$(CP) ./files/etc $(1)/
	$(CP) ./files/sbin $(1)/
	$(CP) ./files/usr $(1)/
	mkdir -p $(1)/lib/voice
	$(CP) ./files/lib/cw.sh $(1)/lib/.
	$(CP) ./files/lib/voice/$(VOICE_LIB) $(1)/lib/voice/voicelib.sh

ifeq ($(CONFIG_TARGET_intel_mips),y)
	sed -i \
	-e 's/brcm/tapi/g' \
	-e 's/BRCM/TAPI/g' \
	-e 's/broadcom/intel/g' \
	$(1)/etc/config/voice_client \
	$(1)/etc/asterisk_templates/*
endif
endef

$(eval $(call BuildPackage,voice-client))
