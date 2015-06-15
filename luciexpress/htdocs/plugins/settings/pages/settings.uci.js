//! Author: Martin K. Schröder <mkschreder.uk@gmail.com>

JUCI.app
.controller("SettingsUCIController", function($scope, $rpc){
	var configs = {}; 
	$scope.loading = 0; 
	function filterHiddenValues(values){
		var ret = {}; 
		Object.keys(values).map(function(v){
			if(v.indexOf(".") != 0) ret[v] = values[v]; 
		}); 
		return ret; 
	}
	$scope.onChangeSection = function(item){
		$scope.selectedConfig = item; 
		$scope.error = ""; 
		$scope.loading = 1; 
		$scope.subsections = {}; 
		$rpc.uci.state({
			config: item.id
		}).done(function(data){
			$scope.subsections = data.values; 
			Object.keys($scope.subsections).map(function(k){
				$scope.subsections[k] = filterHiddenValues($scope.subsections[k]); 
			}); 
			$scope.loading = 0; 
			$scope.$apply(); 
		}).fail(function(err){
			$scope.error = "Could not retreive data!"; 
			$scope.loading = 0; 
			$scope.$apply(); 
		});  
	}
	$scope.onSaveSection = function(id){
		if(!$scope.selectedConfig) return; 
		$scope.error = ""; 
		$rpc.uci.set({
			"config": $scope.selectedConfig.id, 
			"section": id, 
			"values": $scope.subsections[id]
		}).done(function(resp){
			$rpc.uci.commit({
				config: $scope.selectedConfig.id
			}).done(function(resp){
				$scope.onResetSection(id); 
			}); 
		}); 
	}
	$scope.onResetSection = function(id){
		$scope.error = ""; 
		if(!$scope.selectedConfig) return; 
		$rpc.uci.state({
			config: $scope.selectedConfig.id, 
			section: id
		}).done(function(result){
			Object.assign($scope.subsections[id], filterHiddenValues(result.values)); 
			$scope.$apply(); 
		}); 
	}
	async.series([
		function(next){ $rpc.uci.configs().done(function(list){configs = list.configs; next(); }); }, 
	], function(){
		$scope.error = ""; 
		$scope.sections = configs.map(function(x){return {label: x, id: x};}); 
		$scope.$apply(); 
	})
	/*$rpc.uci.state({
		config: "wireless"
	}).done(function(data){
		Object.keys(data.values).map(function(k){
			
		}); 
	}); */
}); 
