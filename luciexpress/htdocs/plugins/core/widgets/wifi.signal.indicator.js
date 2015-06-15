$juci.module("core")
.directive("wifiSignalIndicator", function($compile, $parse){
	var plugin_root = $juci.module("core").plugin_root; 
	return {
		templateUrl: plugin_root+"/widgets/wifi.signal.indicator.html", 
		scope: {
			value: "=ngModel"
		}, 
		controller: "wifiSignalIndicator", 
		replace: true, 
		require: "^ngModel"
	 };  
}).controller("wifiSignalIndicator", function($scope, $uci, $rpc){
	$scope.bars = [false, false, false, false]; 
	$scope.$watch("value", function(value){
		var q = value / 5; 
		$scope.bars[0] = $scope.bars[1] = $scope.bars[2] = $scope.bars[3] = false; 
		if(value > 1) $scope.bars[0] = true; 
		if(value > 2) $scope.bars[1] = true; 
		if(value > 3) $scope.bars[2] = true; 
		if(value > 4) $scope.bars[3] = true; 
	}); 
	$scope.barStyle = function(idx, active){
		var height = 5 + ((idx) * 5); 
		var top = 20 - height; 
		return {
			"position": "absolute", 
			"width": "6px", 
			"height": ""+height+"px", 
			"background-color": (active)?"#aab400":"#d5d5d5",
			"top": ""+top+"px", 
			"left": ""+(idx * 8)+"px"
		}; 
	}
}); 
