#!javascript
global.JUCI = require("../../../../tests/lib-juci"); 
require("../wifi"); 

var completed = {
	"general": 1, 
	"mac_filter": 1, 
	"schedule": 1, 
	"settings": 1, 
	"wps": 0
}

describe("Wireless", function(){
	it("should be completed", function(){
		expect(Object.keys(completed).filter(function(x){ return completed[x] == 0; })).to.be.empty(); 
	}); 
	it("should have wireless config", function(done){
		$uci.sync("wireless").done(function(){
			expect($uci.wireless).to.be.an(Object); 
			done(); 
		}); 
	}); 
	it("should have at least one wireless device and interface defined", function(done){
		expect($uci.wireless["@wifi-device"]).to.be.an(Array); 
		expect($uci.wireless["@wifi-iface"]).to.be.an(Array); 
		expect($uci.wireless["@wifi-device"].length).not.to.be(0); 
		expect($uci.wireless["@wifi-iface"].length).not.to.be(0); 
		done(); 
	}); 
	it("should have boardpanel config present", function(done){
		$uci.sync("boardpanel").done(function(){
			expect($uci.boardpanel).to.be.an(Object); 
			done(); 
		}); 
	}); 
	it("should have boardpanel.settings section present", function(done){
		expect($uci.boardpanel["@settings"]).to.be.an(Array);
		expect($uci.boardpanel.settings).to.be.ok(); 
		done(); 
	}); 
	it("should have boardpanel network section of type services", function(){
		expect($uci.boardpanel["@services"]).to.be.an(Array); 
		expect($uci.boardpanel["@services"]).not.to.be.empty(); 
		expect($uci.boardpanel.network).to.be.ok(); 
	}); 
	it("should have hosts config present", function(done){
		$uci.sync("hosts").done(function(){
			expect($uci.hosts).to.be.an(Object); 
			done(); 
		}); 
	}); 
	it("should have wps.pbc rpc call", function(){
		expect($rpc.wps.pbc).to.be.a(Function); 
	}); 
}); 
