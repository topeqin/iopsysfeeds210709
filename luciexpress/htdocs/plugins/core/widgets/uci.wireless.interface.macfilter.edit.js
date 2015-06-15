$juci.module("core")
.directive("uciWirelessInterfaceMacfilterEdit", function($compile){
	var plugin_root = $juci.module("core").plugin_root; 
	return {
		templateUrl: plugin_root+"/widgets/uci.wireless.interface.macfilter.edit.html", 
		scope: {
			interface: "=ngModel"
		}, 
		controller: "uciWirelessInterfaceMacfilterEditController", 
		replace: true, 
		require: "^ngModel"
	 };  
}).controller("uciWirelessInterfaceMacfilterEditController", function($scope, $rpc, $uci, $hosts){
	$scope.maclist = []; 
	/*
	// updates scratch model for the view
	function updateMaclist(i){
		var maclist = []; 
		if(i && i.maclist) {
			async.eachSeries(i.maclist.value, function(mac, next){
				$hosts.select({ macaddr: mac }).done(function(host){
					maclist.push(host); 
					next(); 
				}).fail(function(){
					$hosts.insert({ hostname: "no name", macaddr: mac }).done(function(host){
						maclist.push(host);
					}).always(function(){ next(); });  
				}); 
			}, function(){
				$scope.maclist = maclist; 
			}); 
		} else {
			$scope.maclist = []; 
		}
	}
	*/
	// watch for model change
	$scope.$watch("interface", function(i){
		$scope.maclist = []; 
		console.log("Syncing interface.."); 
		if(i.maclist && i.maclist.value){
			i.maclist.value.map(function(mac){
				var added = { hostname: "", macaddr: mac}; 
				$uci.hosts["@all"].map(function(host){
					console.log("testing host "+host.hostname.value); 
					if(host.macaddr.value == mac){
						added = { hostname: host.hostname.value, macaddr: mac}; 
					}
				}); 
				$scope.maclist.push(added); 
			});
			//$scope.$apply();  
		}
	}, true); 
	
	// watch maclist for changes by the user
	$scope.rebuildMacList = function(){
		if($scope.interface){
			var newlist = $scope.maclist.map(function(x){
				var found = false; 
				console.log("Looking for mac "+x.macaddr); 
				$uci.hosts["@host"].map(function(host){
					if(host.macaddr.value == x.macaddr) {
						console.log("Setting hostname "+x.hostname+" on "+x.macaddr); 
						host.hostname.value = x.hostname; 
						found = true; 
					}
				}); 
				if(!found){
					$uci.hosts.create({ 
						".type": "host", 
						hostname: x.hostname, 
						macaddr: x.macaddr
					}).done(function(host){
						console.log("Added new host to database: "+host.macaddr.value); 
					}); 
				}
				return x.macaddr || "";  
			}); 
			$scope.interface.maclist.value = newlist;  
		}
	}; 
	
	$rpc.router.clients().done(function(clients){
		$scope.client_list = Object.keys(clients).map(function(x){ 
			return {
				checked: false, 
				client: clients[x]
			}
		});
		$scope.$apply(); 
	}); 
	
	$scope.onDeleteHost = function(host){
		$scope.maclist = ($scope.maclist||[]).filter(function(x) { return x.macaddr != host.macaddr; }); 
	}
	
	$scope.onAddClients = function(){
		// reset all checkboxes 
		if($scope.client_list){
			$scope.client_list.map(function(x){ x.checked = false; }); 
		}
		$scope.showModal = 1; 
	}
	
	$scope.onFilterEnable = function(){
		$scope.filterEnabled = !$scope.filterEnabled; 
		//console.log("Filter: "+$scope.filterEnabled); 
	}
	
	$scope.onAddNewClient = function(){
		$scope.maclist.push({ hostname: "", macaddr: "" }); 
	}
	
	$scope.onAcceptModal = function(){
		if($scope.client_list && $scope.maclist) {
			$scope.client_list.map(function(x){
				if(x.checked) {
					if($scope.maclist.filter(function(a) { return a.macaddr == x.client.macaddr; }).length == 0){
						$scope.maclist.push({ hostname: x.client.hostname, macaddr: x.client.macaddr }); 
					} else {
						console.log("MAC address "+x.client.macaddr+" is already in the list!"); 
					}
				}
			}); 
		}
		$scope.showModal = 0; 
	}
	
	$scope.onDismissModal = function(){
		$scope.showModal = 0; 
	}
}); 
