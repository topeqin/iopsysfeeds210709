//! Author: Martin K. Schröder <mkschreder.uk@gmail.com>

JUCI.app
.controller("WifiWPSPageCtrl", function($scope, $uci, $rpc, $interval, gettext){
	var wps_status_strings = {
		0: gettext("wps.status.init"),
		1: gettext("wps.status.processing"),
		2: gettext("wps.status.success"),
		3: gettext("wps.status.fail"),
		4: gettext("wps.status.timeout"),
		7: gettext("wps.status.msgdone")
	}; 
	
	$scope.data = {
		userPIN: ""
	}
	$scope.progress = 0; 
	
	$uci.sync(["wireless", "boardpanel"]).done(function(){
		if($uci.boardpanel == undefined) $scope.$emit("error", "Boardpanel config is not present on this system!"); 
		else $scope.boardpanel = $uci.boardpanel; 
		if(!$uci.boardpanel.settings){
			$uci.boardpanel.create({".type": "settings", ".name": "settings"}).done(function(section){
				$uci.save(); 
			}).fail(function(){
				$scope.$emit("error", "Could not create required section boardpanel.settings in config!"); 
			}); 
		} 
		$scope.wireless = $uci.wireless; 
		$scope.$apply(); 
	}).fail(function(err){
		console.log("failed to sync config: "+err); 
	}); 
	
	JUCI.interval.repeat("wifi.wps.retry", 1000, function(next){
		$rpc.wps.status().done(function(result){
			$scope.progress = result.code; 
			$scope.text_status = wps_status_strings[result.code]||gettext("wps.status.unknown"); 
			$scope.$apply();	
			next();
		}); 
	}); 
	
	$rpc.wps.showpin().done(function(data){
		$scope.generatedPIN = data.pin; 
	}); 
	
	$scope.save = function(){
		$uci.save(); 
	}
	$scope.onPairPBC = function(){
		$rpc.wps.pbc();
	}
	$scope.onPairUserPIN = function(){
		$rpc.wps.stapin({ pin: $scope.data.userPIN });
	}
	$scope.onGeneratePIN = function(){
		$rpc.wps.genpin().done(function(data){
			$rpc.wps.setpin({pin: data.pin}).done(function(){
				$scope.generatedPIN = data.pin; 
				$scope.$apply(); 
			}); 
		}); 
	}
	
	$scope.onCancelWPS = function(){
		$rpc.wps.stop(); 
	} 
}); 
