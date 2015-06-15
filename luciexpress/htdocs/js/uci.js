//! Author: Martin K. Schröder <mkschreder.uk@gmail.com>

(function(scope){
	//var JUCI = exports.JUCI; 
	var $rpc = scope.UBUS; 
	
	// just for the extractor
	var gettext = function(str) { return str; }; 
	
	function DefaultValidator(){
		this.validate = function(field){
			return null; // return null to signal that there was no error
		}
	}
	
	function TimespanValidator(){
		this.validate = function(field){
			var parts = field.value.split("-"); 
			if(parts.length != 2) return gettext("Please specify both start time and end time for schedule!"); 
			function split(value) { return value.split(":").map(function(x){ return Number(x); }); };
			var from = split(parts[0]);
			var to = split(parts[1]); 
			if(from[0] >= 0 && from[0] < 24 && to[0] >= 0 && to[0] < 24 && from[1] >= 0 && from[1] < 60 && to[1] >= 0 && to[1] < 60){
				if((from[0]*60+from[1]) < (to[0]*60+to[1])) {
					return null; 
				} else {
					return gettext("Schedule start time must be lower than schedule end time!"); 
				}
			} else {
				return gettext("Please enter valid time value for start and end time!"); 
			}
		}
	}
	
	function WeekDayListValidator(){
		this.validate = function(field){
			if(!field.schema.allow) return null; 
			var days_valid = field.value.filter(function(x){
				return field.schema.allow.indexOf(x) != -1; 
			}).length; 
			if(!days_valid) return gettext("Please pick days between mon-sun"); 
			return null; 
		}
	}

	function PortValidator(){
		var PORT_REGEX = /^\d{1,5}$/;

		this.validate = function(field){
			if(field.value == undefined || !field.value.split) return null; 
			var parts = field.value.split("-");
			if (parts.length > 1) {  // check if it is a port range or not
				for (var i = 0; i < parts.length; i++) {
					var outcome = this.validatePort(parts[i]);
					if (outcome != null) { return outcome; }
				}
			} else {
				return this.validatePort(parts)
			}
		};

		this.validatePort = function(port) {
			if (PORT_REGEX.test(port)) { // valid regex
				if (port <= 0 || port > 65535) {
					return gettext("Port value must be between 0 and 65536");
				} else {
					return null;
				}
			} else {
				return gettext("Port value is invalid");
			}
		}
	}
	
	var section_types = {
		"juci": {
			"settings": {
				"theme":					{ dvalue: "", type: String }, 
				"lang":						{ dvalue: "", type: String }, 
				"themes":					{ dvalue: [], type: Array }, 
				"plugins":				{ dvalue: [], type: Array }, 
				"languages":			{ dvalue: [], type: Array }
			}, 
			"test": { // used for unit testing!
				"str":						{ dvalue: "", type: String }, 
				"num":						{ dvalue: 0, type: Number },
				"bool":						{ dvalue: false, type: Boolean }
			}
		}, 
		"boardpanel": {
			"settings": {
				"usb_port": 		{ dvalue: true, type: Boolean }, 
				"status_led": 	{ dvalue: true, type: Boolean }, 
				"power_led": 		{ dvalue: true, type: Boolean }, 
				"power_led_br":	{ dvalue: 100, type: Number },
				"wifibutton": 	{ dvalue: true, type: Boolean },
				"wpsbutton": 		{ dvalue: true, type: Boolean },
				"wpsdevicepin": { dvalue: true, type: Boolean }
			},
			"services": {
				"internet":				{ dvalue: "", type: String },
				"voice":					{ dvalue: "", type: String },
				"iptv":						{ dvalue: "", type: String }
			}
		}, 
		"firewall": {
			"defaults": {
				"syn_flood":		{ dvalue: true, type: Boolean }, 
				"input":				{ dvalue: "ACCEPT", type: String }, 
				"output":				{ dvalue: "ACCEPT", type: String }, 
				"forward":			{ dvalue: "REJECT", type: String }, 
			}, 
			"zone": {
				"name":					{ dvalue: "", type: String }, 
				"input":				{ dvalue: "ACCEPT", type: String }, 
				"output":				{ dvalue: "ACCEPT", type: String }, 
				"forward":			{ dvalue: "REJECT", type: String }, 
				"network": 			{ dvalue: [], type: Array }, 
				"masq":					{ dvalue: true, type: Boolean }, 
				"mtu_fix": 			{ dvalue: true, type: Boolean }
			}, 
			"redirect": {
				"src_ip":				{ dvalue: "", type: String },
				"src_dport":		{ dvalue: 0, type: String, validator: PortValidator },
				"proto":				{ dvalue: "tcp", type: String }, 
				"dest_ip":			{ dvalue: "", type: String }, 
				"dest_port":		{ dvalue: 0, type: String, validator: PortValidator }
			}, 
			"include": {
				"path": 				{ dvalue: "", type: String }, 
				"type": 				{ dvalue: "", type: String }, 
				"family": 			{ dvalue: "", type: String }, 
				"reload": 			{ dvalue: true, type: Boolean }
			}, 
			"dmzhost": {
				"enabled": 			{ dvalue: false, type: Boolean }, 
				"host": 				{ dvalue: "", type: String } // TODO: change to ip address
			}, 
			"rule": {
				"name":					{ dvalue: "", type: String }, 
				"src":					{ dvalue: "lan", type: String }, 
				"src_ip":				{ dvalue: "", type: String }, 
				"src_port":			{ dvalue: 0, type: Number }, 
				"proto":				{ dvalue: "tcp", type: String }, 
				"dest":					{ dvalue: "*", type: String }, 
				"dest_ip":			{ dvalue: "", type: String }, 
				"dest_port":		{ dvalue: 0, type: Number }, 
				"target":				{ dvalue: "REJECT", type: String }, 
				"family": 			{ dvalue: "ipv4", type: String }, 
				"icmp_type": 		{ dvalue: [], type: Array },
				"enabled": 			{ dvalue: true, type: Boolean },
				"hidden": 			{ dvalue: true, type: Boolean }, 
				"limit":				{ dvalue: "", type: String }
			}, 
			"settings": {
				"disabled":			{ dvalue: false, type: Boolean },
				"ping_wan":			{ dvalue: false, type: Boolean }
			}
		}, 
		"system": {
			"system": {
				"timezone":				{ dvalue: '', type: String },
				"zonename":				{ dvalue: '', type: String },
				"conloglevel":		{ dvalue: 0, type: Number },
				"cronloglevel":		{ dvalue: 0, type: Number },
				"hostname":				{ dvalue: '', type: String },
				"displayname":		{ dvalue: '', type: String },
				"log_size":				{ dvalue: 200, type: Number }
			},
			"upgrade": {
				"fw_check_url":		{ dvalue: "", type: String, required: false},
				"fw_path_url":		{ dvalue: "", type: String, required: false},
				"fw_find_ext":		{ dvalue: "", type: String, required: false},
				"fw_down_path":		{ dvalue: "", type: String, required: false}
			}
		},
		"broadcom": {
			"broadcom": {
				"init": { dvalue: '1', type: String }, 
				"debug": { dvalue: '0', type: String }, 
				"wl0_cfgno": { dvalue: '', type: String }, 
				"wl0_reg_mode": { dvalue: 'h', type: String }, 
				"wl_5g_radio": { dvalue: 'wl0', type: String }, 
				"wl0_acs_chan_dwell_time": { dvalue: '70', type: String }, 
				"wl0_acs_chan_flop_period": { dvalue: '70', type: String }, 
				"wl0_acs_ci_scan_timeout": { dvalue: '300', type: String }, 
				"wl0_acs_ci_scan_timer": { dvalue: '4', type: String }, 
				"wl0_acs_cs_scan_timer": { dvalue: '7200', type: String }, 
				"wl0_acs_scan_entry_expire": { dvalue: '3600', type: String }, 
				"wl0_acs_tx_idle_cnt": { dvalue: '5', type: String }, 
				"wl0_acs_lowband_least_rssi": { dvalue: '-75', type: String }, 
				"wl0_acs_fcs_mode": { dvalue: '0', type: String }, 
				"wl0_acs_dfs": { dvalue: '1', type: String }, 
				"wl0_acs_dfsr_activity": { dvalue: '30 10240', type: String }, 
				"wl0_acs_dfsr_deferred": { dvalue: '604800 5', type: String }, 
				"wl0_acs_dfsr_immediate": { dvalue: '300 3', type: String }, 
				"wl0_apsta": { dvalue: '0', type: String }, 
				"wl0_mode": { dvalue: 'ap', type: String }, 
				"wl0_ifname": { dvalue: 'wl0', type: String }, 
				"wl0_ssid": { dvalue: '', type: String }, 
				"wl0_radio": { dvalue: '1', type: String }, 
				"wl0_infra": { dvalue: '1', type: String }, 
				"wl0_auth": { dvalue: '0', type: String }, 
				"wl0_preauth": { dvalue: '0', type: String }, 
				"wl0_net_auth_type": { dvalue: '1', type: String }, 
				"wl0_wep": { dvalue: 'disabled', type: String }, 
				"wl0_wpa_gtk_rekey": { dvalue: '0', type: String }, 
				"wl0_akm": { dvalue: 'psk psk2', type: String }, 
				"wl0_crypto": { dvalue: 'tkip+aes', type: String }, 
				"wl0_wpa_psk": { dvalue: '', type: String }, 
				"wl0_auth_mode": { dvalue: 'psk', type: String }, 
				"wl0_wps_mode": { dvalue: 'enabled', type: String }, 
				"router_disable": { dvalue: '0', type: String }, 
				"wps_modelnum": { dvalue: '', type: String }, 
				"boardnum": { dvalue: '', type: String }, 
				"wps_modelname": { dvalue: 'Broadcom', type: String }, 
				"wps_mfstring": { dvalue: 'Broadcom', type: String }, 
				"wps_device_name": { dvalue: 'Inteno', type: String }, 
				"wps_version2": { dvalue: 'enabled', type: String }, 
				"lan_wps_reg": { dvalue: 'enabled', type: String }, 
				"lan_wps_oob": { dvalue: 'disabled', type: String }, 
				"wps_button_gpio": { dvalue: '22', type: String }, 
				"wps_oob_configured": { dvalue: '1', type: String }, 
				"wps_config": { dvalue: 'DONE', type: String }, 
				"wl0_vifs": { dvalue: 'wl0', type: String }, 
				"wl0_network": { dvalue: 'lan', type: String }, 
				"wl0_bss_enabled": { dvalue: '1', type: String }, 
				"wl0_hwaddr": { dvalue: '', type: String }, 
				"wl_main_ifnames": { dvalue: 'wl0 wl1', type: String }, 
				"wl1_cfgno": { dvalue: '', type: String }, 
				"wl_2g_radio": { dvalue: 'wl1', type: String }, 
				"acs_ifnames": { dvalue: 'wl0 wl1', type: String }, 
				"wl1_acs_chan_dwell_time": { dvalue: '70', type: String }, 
				"wl1_acs_chan_flop_period": { dvalue: '70', type: String }, 
				"wl1_acs_ci_scan_timeout": { dvalue: '300', type: String }, 
				"wl1_acs_ci_scan_timer": { dvalue: '4', type: String }, 
				"wl1_acs_cs_scan_timer": { dvalue: '7200', type: String }, 
				"wl1_acs_scan_entry_expire": { dvalue: '3600', type: String }, 
				"wl1_acs_tx_idle_cnt": { dvalue: '5', type: String }, 
				"wl1_acs_lowband_least_rssi": { dvalue: '-75', type: String }, 
				"wl1_acs_fcs_mode": { dvalue: '1', type: String }, 
				"wl1_acs_dfs": { dvalue: '0', type: String }, 
				"wl1_apsta": { dvalue: '0', type: String }, 
				"wl1_mode": { dvalue: 'ap', type: String }, 
				"wl1_ifname": { dvalue: 'wl1', type: String }, 
				"wl1_ssid": { dvalue: '', type: String }, 
				"wl1_radio": { dvalue: '1', type: String }, 
				"wl1_infra": { dvalue: '1', type: String }, 
				"wl1_auth": { dvalue: '0', type: String }, 
				"wl1_preauth": { dvalue: '0', type: String }, 
				"wl1_net_auth_type": { dvalue: '1', type: String }, 
				"wl1_wep": { dvalue: 'disabled', type: String }, 
				"wl1_wpa_gtk_rekey": { dvalue: '0', type: String }, 
				"wl1_akm": { dvalue: 'psk psk2', type: String }, 
				"wl1_crypto": { dvalue: 'tkip+aes', type: String }, 
				"wl1_wpa_psk": { dvalue: '', type: String }, 
				"wl1_auth_mode": { dvalue: 'psk', type: String }, 
				"wl1_wps_mode": { dvalue: 'enabled', type: String }, 
				"wl1_vifs": { dvalue: 'wl1', type: String }, 
				"wl1_network": { dvalue: 'lan', type: String }, 
				"wl1_bss_enabled": { dvalue: '1', type: String }, 
				"wl1_hwaddr": { dvalue: '', type: String }, 
				"wlmngr": { dvalue: 'done', type: String }, 
				"lan_ifname": { dvalue: 'br-lan', type: String }, 
				"lan_ifnames": { dvalue: '', type: String }, 
				"wps_device_pin": { dvalue: '', type: String }, 
				"wps_config_method": { dvalue: '0x2688', type: String }, 
				"wps_aplockdown": { dvalue: '0', type: String }, 
				"wps_button": { dvalue: '0', type: String }, 
				"wps_sta_pin": { dvalue: '00000000', type: String }, 
				"wl_unit": { dvalue: '0', type: String }, 
				"wps_proc_status": { dvalue: 0, type: Number }
			}
		}, 
		//"ddns": {
		//    "interface":            { dvalue: "", type: String },
		//    "enabled":              { dvalue: 0, type: Number },
		//    "service_name":         { dvalue: "", type: String },
		//    "domain":               { dvalue: "", type: String },
		//    "username":             { dvalue: "", type: String },
		//    "password":             { dvalue: "", type: String }
		//},
	}; 
	function UCI(){
		
	}
	(function(){
		function UCIField(value, schema){
			if(!schema) throw new Error("No schema specified for the field!"); 
			this.ovalue = value; 
			if(value != null && value instanceof Array) {
				this.ovalue = []; Object.assign(this.ovalue, value); 
			} 
			this.dirty = false; 
			this.uvalue = undefined; 
			this.schema = schema; 
			if(schema.validator) this.validator = new schema.validator(); 
			else this.validator = new DefaultValidator(); 
		}
		UCIField.prototype = {
			$reset: function(value){
				this.ovalue = this.uvalue = value; 
				if(value != null && value instanceof Array) {
					this.ovalue = []; Object.assign(this.ovalue, value); 
				}
				this.dirty = false; 
			}, 
			get value(){
				if(this.uvalue == undefined) return this.ovalue;
				else return this.uvalue; 
			},
			set value(val){
				if(!this.dirty && this.ovalue != val) this.dirty = true; 
				this.uvalue = val; 
			},
			get error(){
				return this.validator.validate(this); 
			},
			get valid(){
				return this.validator.validate(this) == null; 
			}
		}
		UCI.Field = UCIField; 
	})(); 
	(function(){
		function UCISection(config){
			this[".config"] = config; 
		}
		
		UCISection.prototype.$update = function(data){
			if(!(".type" in data)) throw new Error("Supplied object does not have required '.type' field!"); 
			// try either <config>-<type> or just <type>
			var sconfig = section_types[this[".config"][".name"]]; 
			if((typeof sconfig) == "undefined") throw new Error("Missing type definition for config "+this[".config"][".name"]+"!"); 
			var type = 	sconfig[data[".type"]]; 
			if(!type) {
				console.error("Section.$update: unrecognized section type "+this[".config"][".name"]+"-"+data[".type"]); 
				return; 
			}
			var self = this; 
			self[".original"] = data; 
			self[".name"] = data[".name"]; 
			self[".type"] = data[".type"]; 
			self[".section_type"] = type; 
			
			Object.keys(type).map(function(k){
				var field = self[k]; 
				if(!field) { field = self[k] = new UCI.Field("", type[k]); }
				var value = type[k].dvalue; 
				if(!(k in data)) { 
					//console.log("Field "+k+" missing in data!"); 
				} else {
					switch(type[k].type){
						case String: value = data[k]; break; 
						case Number: 
							var n = Number(data[k]); 
							if(isNaN(n)) n = type.dvalue;
							value = n; 
							break; 
						case Array: 
							if(data[k] instanceof String) value = [data[k]]; 
							else value = data[k];  
							break; 
						case Boolean: 
							if(data[k] === "true" || data[k] === "1") value = true; 
							else if(data[k] === "false" || data[k] === "0") value = false; 
							break; 
						default: 
							value = data[k]; 
					}
				}
				field.$reset(value); 
			}); 
		}
		
		UCISection.prototype.$sync = function(){
			var deferred = $.Deferred(); 
			var self = this; 

			$rpc.uci.state({
				config: self[".config"][".name"], 
				section: self[".name"]
			}).done(function(data){
				self.$update(data.values);
				deferred.resolve(); 
			}).fail(function(){
				deferred.reject(); 
			}); 
			return deferred.promise(); 
		}
		
		UCISection.prototype.$save = function(){
			var deferred = $.Deferred(); 
			var self = this; 
			
			$rpc.uci.set({
				config: self[".config"][".name"], 
				section: self[".name"], 
				values: self.$getChangedValues()
			}).done(function(data){
				deferred.resolve(); 
			}).fail(function(){
				deferred.reject(); 
			}); 
			return deferred.promise(); 
		}
		
		UCISection.prototype.$delete = function(){
			var self = this; 
			if(self[".config"]) return self[".config"].$deleteSection(self); 
			var def = $.Deferred(); 
			setTimeout(function(){
				def.reject(); 
			}, 0); 
			return def.promise(); 
		}
		
		UCISection.prototype.$getErrors = function(){
			var errors = []; 
			var self = this; 
			var type = self[".section_type"]; 
			Object.keys(type).map(function(k){
				if(self[k] && self[k].error){
					errors.push(self[k].error); 
				}
			}); 
			return errors; 
		}
		
		UCISection.prototype.$getChangedValues = function(){
			var type = this[".section_type"]; 
			if(!type) return {}; 
			var self = this; 
			var changed = {}; 
			Object.keys(type).map(function(k){
				if(self[k] && self[k].dirty){ 
					//console.log("Adding dirty field: "+k); 
					changed[k] = self[k].value; 
				}
			}); 
			return changed; 
		}
		UCI.Section = UCISection; 
	})(); 
	(function(){
		function UCIConfig(uci, name){
			var self = this; 
			self.uci = uci; 
			self[".name"] = name; 
			self["@all"] = []; 
			if(!name in section_types) throw new Error("Missing type definition for config "+name); 
			
			// set up slots for all known types of objects so we can reference them in widgets
			Object.keys(section_types[name]||{}).map(function(type){
				self["@"+type] = []; 
			}); 
			//this["@deleted"] = []; 
		}
		
		function _insertSection(self, item){
			console.log("Adding local section: "+self[".name"]+"."+item[".name"]); 
			var section = new UCI.Section(self); 
			section.$update(item); 
			var type = "@"+item[".type"]; 
			if(!(type in self)) self[type] = []; 
			self[type].push(section); 
			self["@all"].push(section); 
			self[item[".name"]] = section; 
			return section; 
		}
		function _updateSection(self, item){
			var section = self[item[".name"]]; 
			if(section && section.$update) section.$update(item); 
		}
		
		function _unlinkSection(self, section){
			// NOTE: can not use filter() because we must edit the list in place 
			// in order to play well with controls that reference the list! 
			console.log("Removing local section: "+self[".name"]+"."+section[".name"]+" of type "+section[".type"]); 
			var all = self["@all"]; 
			for(var i = 0; i < all.length; i++){
				if(all[i][".name"] === section[".name"]) {
					all.splice(i, 1); 
					break; 
				}; 
			}
			var jlist = self["@"+section[".type"]]||[]; 
			for(var j = 0; j < jlist.length; j++){
				if(jlist[j][".name"] === section[".name"]) {
					jlist.splice(j, 1); 
					break; 
				}
			}
			if(section[".name"]) delete self[section[".name"]]; 
		}
		
		UCIConfig.prototype.$sync = function(){
			var deferred = $.Deferred(); 
			var self = this; 
			
			var to_delete = {}; 
			Object.keys(self).map(function(x){
				if(self[x].constructor == UCI.Section) to_delete[x] = self[x]; 
			}); 
			//console.log("To delete: "+Object.keys(to_delete)); 
			$rpc.uci.revert({
				config: self[".name"]//, 
				//ubus_rpc_session: $rpc.$sid()
			}).always(function(){ // we have to use always because we always want to sync regardless if reverts work or not ( they will not if the config is readonly! )
				$rpc.uci.state({
					config: self[".name"]
				}).done(function(data){
					var vals = data.values;
					Object.keys(vals).filter(function(x){
						return vals[x][".type"] in section_types[self[".name"]]; 
					}).map(function(k){
						if(!(k in self)) _insertSection(self, vals[k]); 
						else _updateSection(self, vals[k]); 
						delete to_delete[k]; 
					}); 
					
					// now delete any section that no longer exists in our local cache
					async.eachSeries(Object.keys(to_delete), function(x, next){
						var section = to_delete[x]; 
						//console.log("Would delete section "+section[".name"]+" of type "+section[".type"]); 
						_unlinkSection(self, section); 
						next(); 
					}, function(){
						deferred.resolve();
					});  
				}).fail(function(){
					deferred.reject(); 
				}); 
			}); 
			return deferred.promise(); 
		}
		// set object values on objects that match search criteria 
		// if object does not exist, then create a new object 
		UCIConfig.prototype.set = function(search, values){
			var self = this; 
			self["@all"].map(function(item){
				var match = Object.keys(search).filter(function(x){ item[x] != search[x]; }).length == 0; 
				if(match){
					Object.keys(values).map(function(x){
						item[x].value = values[x]; 
					}); 
				}
			}); 
		}
		
		UCIConfig.prototype.$registerSectionType = function(name, descriptor){
			var config = this[".name"]; 
			var conf_type = section_types[config]; 
			if(typeof conf_type === "undefined") conf_type = section_types[config] = {}; 
			conf_type[name] = descriptor; 
			this["@"+name] = []; 
			console.log("Registered new section type "+config+"."+name); 
		}
		
		UCIConfig.prototype.$deleteSection = function(section){
			var self = this; 
			var deferred = $.Deferred(); 
			console.log("Deleting section "+self[".name"]+"."+section[".name"]); 
			
			//self[".need_commit"] = true; 
			$rpc.uci.delete({
				"config": self[".name"], 
				"section": section[".name"]
			}).done(function(){
				_unlinkSection(self, section); 
				self[".need_commit"] = true; 
				deferred.resolve(); 
			}).fail(function(){
				console.error("Failed to delete section!"); 
				deferred.reject(); 
			}); 
			return deferred.promise(); 
		}
		
		// creates a new object that will have values set to values
		UCIConfig.prototype.create = function(item, offline){
			var self = this; 
			if(!(".type" in item)) throw new Error("Missing '.type' parameter!"); 
			var type = section_types[self[".name"]][item[".type"]]; 
			if(!type) throw Error("Trying to create section of unrecognized type!"); 
			
			// TODO: validate values!
			var values = {}; 
			Object.keys(type).map(function(k){ 
				if(k in item) values[k] = item[k]; 
				else {
					if(type[k].required) throw Error("Missing required field "+k); 
					values[k] = type[k].dvalue; 
				}
			}); 
			var deferred = $.Deferred(); 
			
			if((".name" in item) && (item[".name"] in self)){ // section with specified name already exists
				setTimeout(function(){
					deferred.reject("Section with name "+item[".name"]+" already exists in config "+self[".name"]); 
				}, 0); 
				return deferred.promise(); 
			}
			
			console.log("Adding: "+item[".type"]+": "+JSON.stringify(values)); 
			$rpc.uci.add({
				"config": self[".name"], 
				"type": item[".type"],
				"name": item[".name"], 
				"values": values
			}).done(function(state){
				console.log("Added new section: "+state.section); 
				item[".name"] = state.section; 
				self[".need_commit"] = true; 
				var section = _insertSection(self, item); 
				//section[".new"] = true; 
				deferred.resolve(section); 
			}).fail(function(){
				deferred.reject(); 
			});
			return deferred.promise(); 
		}
		
		
		UCIConfig.prototype.$getWriteRequests = function(){
			var self = this; 
			var reqlist = []; 
			self["@all"].map(function(section){
				var changed = section.$getChangedValues(); 
				//console.log(JSON.stringify(changed) +": "+Object.keys(changed).length); 
				if(Object.keys(changed).length){
					reqlist.push({
						"config": self[".name"], 
						"section": section[".name"], 
						"values": changed
					}); 
				}
			}); 
			return reqlist; 
		}
		
		UCI.Config = UCIConfig; 
	})(); 
	
	UCI.prototype.$init = function(){
		var deferred = $.Deferred(); 
		console.log("Init UCI"); 
		var self = this; 
		if(!$rpc.uci) {
			setTimeout(function(){ deferred.reject(); }, 0); 
			return deferred.promise(); 
		}
		
		$rpc.uci.configs().done(function(response){
			var cfigs = response.configs; 
			if(!cfigs) { next("could not retrieve list of configs!"); return; }
			cfigs.map(function(k){
				if(!(k in section_types)) {
					console.log("Missing type definition for config "+k); 
					return; 
				}
				if(!(k in self)){
					//console.log("Adding new config "+k); 
					self[k] = new UCI.Config(self, k); 
				}
			}); 
			deferred.resolve(); 
		}).fail(function(){
			deferred.reject(); 
		}); 
		return deferred.promise(); 
	}
	
	UCI.prototype.$registerConfig = function(name){
		if(!(name in section_types)) section_types[name] = {}; 
		if(!(name in this)) this[name] = new UCI.Config(this, name); 
	}
	
	UCI.prototype.$eachConfig = function(cb){
		var self = this; 
		Object.keys(self).filter(function(x){ 
			return self[x].constructor == UCI.Config; 
		}).map(function(x){
			cb(self[x]); 
		});
	}
	 
	UCI.prototype.sync = function(configs){
		var deferred = $.Deferred(); 
		var self = this; 
		
		async.series([
			function(next){
				if(configs == undefined || configs.length == 0) { 
					// if no argument provided then we sync all configs
					configs = Object.keys(self).filter(function(x){ 
						return self[x].constructor == UCI.Config; 
					}); 
					//next(); return; 
				} else if(!(configs instanceof Array)) {
					configs = [configs]; 
				}
				async.eachSeries(configs, function(cf, next){
					if(!(cf in self)) { 
						//throw new Error("invalid config name "+cf); 
						// NOTE: this can not throw because we need to sync all configs that we can sync
						// TODO: decide on whether to always resolve if at least one config compiles
						// or to always reject if at least one config fails. 
						next(); 
						return; 
					}; 
					self[cf].$sync().done(function(){
						console.log("Synched config "+cf); 
						
						next(); 
					}).fail(function(){
						console.error("Could not sync config "+cf); 
						next(); // continue because we want to sync as many as we can!
						//next("Could not sync config "+cf); 
					}); 
				}, function(err){
					next(err); 
				}); 
			}
		], function(err){
			setTimeout(function(){ // in case async did not defer
				if(err) deferred.reject(err); 
				else deferred.resolve(); 
			}, 0); 
		}); 
		return deferred.promise(); 
	}
	
	UCI.prototype.$revert = function(){
		var revert_list = []; 
		var deferred = $.Deferred(); 
		var errors = []; 
		var self = this; 
		
		Object.keys(self).map(function(k){
			if(self[k].constructor == UCI.Config){
				if(self[k][".need_commit"]) revert_list.push(self[k][".name"]); 
			}
		}); 
		async.eachSeries(revert_list, function(item, next){
			$rpc.uci.revert({"config": item[".name"], "ubus_rpc_session": $rpc.$sid()}).done(function(){
				console.log("Reverted config "+item[".name"]); 
				next(); 
			}).fail(function(){
				errors.push("Failed to revert config "+item[".name"]); 
				next(); 
			}); 
		}, function(){
			if(errors.length) deferred.reject(errors); 
			else deferred.resolve(); 
		}); 
		return deferred.promise(); 
	}
	
	UCI.prototype.save = function(){
		var deferred = $.Deferred(); 
		var self = this; 
		var writes = []; 
		var add_requests = []; 
		var resync = {}; 
		
		async.series([
			function(next){ // commit configs that need committing first
				var commit_list = []; 
				Object.keys(self).map(function(k){
					if(self[k].constructor == UCI.Config){
						if(self[k][".need_commit"]) commit_list.push(self[k][".name"]); 
					}
				}); 
				async.each(commit_list, function(config, next){
					console.log("Committing changes to "+config); 
					$rpc.uci.commit({config: config}).done(function(){
						next(); 
					}).fail(function(err){
						next("could not commit config: "+err); 
					});
				}, function(){
					next(); 
				});
			}, 
			function(next){ // send all changes to the server
				Object.keys(self).map(function(k){
					if(self[k].constructor == UCI.Config){
						var reqlist = self[k].$getWriteRequests(); 
						reqlist.map(function(x){ writes.push(x); });  
					}
				}); 
				console.log("Will do following write requests: "+JSON.stringify(writes)); 
				async.eachSeries(writes, function(cmd, next){
					$rpc.uci.set(cmd).done(function(){
						console.log("Wrote config "+cmd.config); 
						resync[cmd.config] = true; 
						next(); 
					}).fail(function(){
						console.error("Failed to write config "+cmd.config); 
						next(); 
					}); 
				}, function(){
					next(); 
				}); 
			}, 
			function(next){
				async.eachSeries(Object.keys(resync), function(config, next){
					console.log("Committing changes to "+config); 
					$rpc.uci.commit({config: config}).done(function(){
						self[config][".need_commit"] = false; 
						self[config].$sync().done(function(){
							next(); 
						}).fail(function(err){
							console.log("error synching config "+config+": "+err); 
							next("syncerror"); 
						}); 
					}).fail(function(err){
						next("could not commit config: "+err); 
					}); 
				}, function(err){
					// this is to always make sure that we do this outside of this code flow
					setTimeout(function(){
						if(err) deferred.reject(err); 
						else deferred.resolve(err); 
					},0); 
				}); 
			}
		]); 
		return deferred.promise(); 
	}
	
	scope.UCI = new UCI(); 
	scope.UCI.validators = {
		WeekDayListValidator: WeekDayListValidator, 
		TimespanValidator: TimespanValidator, 
		PortValidator: PortValidator
	}; 
	/*if(exports.JUCI){
		var JUCI = exports.JUCI; 
		JUCI.uci = exports.uci = new UCI(); 
		if(JUCI.app){
			JUCI.app.factory('$uci', function(){
				return $juci.uci; 
			}); 
		}
	}*/
})(typeof exports === 'undefined'? this : global); 
