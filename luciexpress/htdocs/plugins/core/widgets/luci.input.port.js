JUCI.app
	.directive("luciInputPort", function () {
		var plugin_root = $juci.module("core").plugin_root;
		return {
			templateUrl: plugin_root + "/widgets/luci.input.port.html",
			restrict: 'E',
			replace: true,
			scope: {
				model: "=ngModel", 
				portRange: "="
			},
			require: "ngModel", 
			controller: "luciInputPortController"
		};
	})
	.controller("luciInputPortController", function($scope, $log) {
		$scope.startPort = ""; 
		$scope.endPort = ""; 
		$scope.port = ""; 
		
		$scope.$watch("model", function(value){
			if($scope.portRange && value && value.split){
				var parts = value.split("-"); 
				$scope.startPort = parts[0]||""; 
				$scope.endPort = parts[1]||""; 
			} else {
				$scope.port = value; 
			}
		}); 
		(function(){
			function updateModel(value){
				//console.log("Update: "+value+": "+$scope.model); 
				if($scope.portRange) {
					$scope.model = $scope.startPort + "-" + $scope.endPort; 
					$scope.port = $scope.startPort; 
				} else {
					// filter out anything that is not a number
					var port = String($scope.port).replace(/[^0-9]*/g, "");
					$scope.model = $scope.port = port; 
					$scope.endPort = ""; 
					$scope.startPort = $scope.port; 
				}
			}
			$scope.$watch("startPort", updateModel); 
			$scope.$watch("endPort", updateModel); 
			$scope.$watch("port", updateModel); 
		})(); 
	});
