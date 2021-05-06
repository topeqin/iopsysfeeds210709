include $(TOPDIR)/rules.mk

PKG_NAME:=juci

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://dev.iopsys.eu/iopsys/juci.git
PKG_SOURCE_VERSION:=70b66bfc7f0e25e77b6920c3d44e5b05f4bfcf95
PKG_VERSION:=2020-05-27
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_RELEASE=$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/juci
  $(Package/juci/default)
  SECTION:=juci
  CATEGORY:=JUCI
  MENU=1
  TITLE:=JUCI Core Package (select this to select default plugins)
  DEPENDS:=+libubox +libubus +owsd +rpcd +rpcd-mod-file +questd
endef

define Build/InstallDev 
	$(INSTALL_DIR) $(1)/usr/src/
	ln -s $(PKG_BUILD_DIR) $(1)/usr/src/juci
endef 

define Build/Compile
	$(call Build/Compile/Default,THEME_PATH="$(TOPDIR)/tmp/juci-themes/")
endef

define Package/juci/description
 JUCI Javascript UCI Web interface.
endef

define Package/juci/install
	$(INSTALL_DIR) $(1)/
	$(CP) $(PKG_BUILD_DIR)/bin/juci/* $(1)/
	$(CP) ./files/* $(1)/
endef

define Package/juci/postinst
#!/bin/sh

juci-update
exit 0
endef

$(eval $(call BuildPackage,juci))

####### Extensions / Themes and Plugins

define RegisterAddonInner
define Package/$(2)
	SECTION:=juci
	CATEGORY:=JUCI
	TITLE:=default
	SUBMENU:=$(1)
	TITLE:=$(if $(3),$(3),JUCI $(2) plugin)
	DEPENDS:=$(4)
endef

define Package/$(2)/install
	$(INSTALL_DIR) $$(1)/
	$(CP) $(PKG_BUILD_DIR)/bin/$(2)/* $$(1)/
endef
endef

define RegisterAddon
	$(eval $(call RegisterAddonInner,$(1),$(2),$(3),$(4),$(5)))
	$(eval $(call BuildPackage,$(2)))
endef

$(eval $(call RegisterAddon,Plugins,juci-catv, CATV Module,@(PACKAGE_catv)))
$(eval $(call RegisterAddon,Plugins,juci-cgroups, CGroups Module,@(PACKAGE_icgroupd)))
$(eval $(call RegisterAddon,Plugins,juci-ddns, DDNS Configuration,@(PACKAGE_ddns-scripts)))
$(eval $(call RegisterAddon,Plugins,juci-diagnostics, Simple Diagnostics,@(PACKAGE_busybox)))
$(eval $(call RegisterAddon,Plugins,juci-ndt, NDT Speed Test client,@(PACKAGE_ndt)))
$(eval $(call RegisterAddon,Plugins,juci-dnsmasq-dhcp, DHCP/DNSMasq Configuration,@(PACKAGE_dnsmasq||PACKAGE_dnsmasq-full)))
$(eval $(call RegisterAddon,Plugins,juci-dropbear, Dropbear Configuration,@(PACKAGE_dropbear)))
$(eval $(call RegisterAddon,Plugins,juci-easyqos, Easy QoS module,@(PACKAGE_easy-qos)))
$(eval $(call RegisterAddon,Plugins,juci-event, Event Module,@(PACKAGE_owsd)))
$(eval $(call RegisterAddon,Plugins,juci-firewall-fw3, Firewall Configuration,@(PACKAGE_firewall)))
$(eval $(call RegisterAddon,Plugins,juci-icwmp, TR-069 Module,@(PACKAGE_icwmp)))
$(eval $(call RegisterAddon,Plugins,juci-config-backup, Config Backup Module))
$(eval $(call RegisterAddon,Plugins,juci-qos, QoS module,@(PACKAGE_qos-scripts)))
$(eval $(call RegisterAddon,Plugins,juci-voice-client, Asterisk Voice Client Module,@(PACKAGE_asterisk)))
$(eval $(call RegisterAddon,Plugins,juci-minidlna, MiniDLNA Configuration,@(PACKAGE_minidlna)))
$(eval $(call RegisterAddon,Plugins,juci-mcproxy, Multicast Proxy Configuration,@(PACKAGE_mcproxy)))
$(eval $(call RegisterAddon,Plugins,juci-mod-status, Status Reporting Module,@(PACKAGE_questd)))
$(eval $(call RegisterAddon,Plugins,juci-mod-system, System Administration Module))
$(eval $(call RegisterAddon,Plugins,juci-mwan3, mwan3 Configuration,@(PACKAGE_mwan3)))
$(eval $(call RegisterAddon,Plugins,juci-natalie-dect, DECT Module,@(PACKAGE_dectmngr2)))
$(eval $(call RegisterAddon,Plugins,juci-netmode, Netmode Module,@(PACKAGE_netmode)))
$(eval $(call RegisterAddon,Plugins,juci-network-device, Network Device Configuration,@(PACKAGE_netifd)))
$(eval $(call RegisterAddon,Plugins,juci-network-dsl, DSL Module))
$(eval $(call RegisterAddon,Plugins,juci-network-netifd, Network Module,@(PACKAGE_netifd)))
$(eval $(call RegisterAddon,Plugins,juci-network-port, Ethernet Port Configuration,@(PACKAGE_port-management)))
$(eval $(call RegisterAddon,Plugins,juci-openvpn, OpenVPN configuration,@(PACKAGE_openvpn)))
$(eval $(call RegisterAddon,Plugins,juci-owsd, OWSD configuration,@(PACKAGE_owsd)))
$(eval $(call RegisterAddon,Plugins,juci-printer, p910nd Printer Server Configuration,@(PACKAGE_p910nd)))
#$(eval $(call RegisterAddon,Plugins,juci-realtime-graphs, Realtime Graphs))
$(eval $(call RegisterAddon,Plugins,juci-samba, Samba Configuration,@(PACKAGE_samba3)))
$(eval $(call RegisterAddon,Plugins,juci-sfp, SFP Configuration,@(PACKAGE_peripheral_manager)))
$(eval $(call RegisterAddon,Plugins,juci-snmpd, SNMP Module,@(PACKAGE_snmpd)))
$(eval $(call RegisterAddon,Plugins,juci-sysupgrade, Sysupgrade Firmware Upgrade,@(PACKAGE_rpcd-mod-rpcsys)))
$(eval $(call RegisterAddon,Plugins,juci-uhttpd, uHTTPD Configuration,@(PACKAGE_uhttpd)))
$(eval $(call RegisterAddon,Plugins,juci-upnp, UPnP Configuration Module,@(PACKAGE_miniupnpd)))
#$(eval $(call RegisterAddon,Plugins,juci-usb, USB Module))
$(eval $(call RegisterAddon,Plugins,juci-wireless, Wireless Management Module))
$(eval $(call RegisterAddon,Plugins,juci-wifilife, WiFi Life Module,@(PACKAGE_wifilife)))
$(eval $(call RegisterAddon,Themes,juci-theme-iopsys))

####### dynamically publish themes as packages #######
$(foreach th,$(wildcard $(TOPDIR)/tmp/juci-themes/*),$(eval $(call RegisterAddon,Themes,$(notdir $(th)))))
