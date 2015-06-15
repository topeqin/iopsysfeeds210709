/*
 * juci - javascript universal client interface
 *
 * Project Author: Martin K. Schröder <mkschreder.uk@gmail.com>
 * 
 * Copyright (C) 2012-2013 Inteno Broadband Technology AB. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */
 
$juci.module("phone")
.controller("PhoneRingingScheduleCtrl", function($scope, $uci){
	$scope.allSipAccountsMap = {}; 
	
	$uci.sync(["voice_client"]).done(function(){
		// TODO add config for phone
		$scope.settings = $uci.voice_client.RINGING_STATUS; 
		$scope.schedules = $uci.voice_client["@ringing_schedule"]; 
		$scope.allSipAccountsMap = {}; 
		$scope.allSipAccounts = $uci.voice_client["@sip_service_provider"].map(function(x){
			var i = {
				label: x.name.value, 
				value: x[".name"]
			}; 
			$scope.allSipAccountsMap[x[".name"]] = x; 
			return i; 
		}); 
	}); 
	
	$scope.onAcceptSchedule = function(){
		//$uci.save().done(function(){
		var schedule = $scope.schedule; 
		var errors = schedule.$getErrors(); 
		
		if(errors && errors.length){
			$scope.errors = errors; 
		} else {
			$scope.errors = []; 
			$scope.showScheduleDialog = 0; 
		}
	}
	
	$scope.onDismissSchedule = function(schedule){
		if($scope.schedule[".new"]){
			$scope.schedule.$delete().done(function(){
				$scope.showScheduleDialog = 0; 
				$scope.$apply(); 
			}); 
		} else {
			$scope.showScheduleDialog = 0; 
		}
	}
	
	$scope.onAddSchedule = function(){
		$uci.voice_client.create({".type": "ringing_schedule"}).done(function(item){
			$scope.schedule = item; 
			$scope.schedule[".new"] = true; 
			$scope.showScheduleDialog = 1; 
			$scope.$apply(); 
			console.log("Added new schedule!"); 
		}).fail(function(err){
			console.log("Failed to create schedule!"); 
		}); ; 
	}
	
	$scope.onEditSchedule = function(sched){
		console.log("Editing: "+sched[".name"]); 
		$scope.schedule = sched; 
		$scope.showScheduleDialog = 1; 
	}
	$scope.onDeleteSchedule = function(sched){
		sched.$delete().always(function(){
			$scope.$apply(); 
		}); 
	}
}); 
