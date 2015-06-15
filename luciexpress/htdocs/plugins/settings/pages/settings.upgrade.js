;(jQuery && jQuery.fn.upload) || (function( $) {
		// abort if xhr progress is not supported
	if( !($.support.ajaxProgress = ("onprogress" in $.ajaxSettings.xhr()))) {
		return;
	}

	var _ajax = $.ajax;
	$.ajax = function ajax( url, options) {
			// If url is an object, simulate pre-1.5 signature
		if ( typeof( url) === "object" ) {
			options = url;
			url = options.url;
		}

			// Force options to be an object
		options = options || {};

		var deferred = $.Deferred();
		var _xhr = options.xhr || $.ajaxSettings.xhr;
		var jqXHR;
		options.xhr = function() {
				// Reference to the extended options object
			var options = this;
			var xhr = _xhr.call( $.ajaxSettings);
			if( xhr) {
				var progressListener = function( /*true | false*/upload) {
					return function( event) {
						/*
						 * trigger the global event.
						 * function handler( jqEvent, progressEvent, upload, jqXHR) {}
						 */
						options.global && $.event.trigger( "ajaxProgress", [ event, upload, jqXHR]);

							/*
							 * trigger the local event.
							 * function handler(jqXHR, progressEvent, upload)
							 */
						$.isFunction( options.progress) && options.progress( jqXHR, event, upload);

						deferred.notifyWith( jqXHR, [event, upload]);
					};
				};

				xhr.upload.addEventListener( "progress", progressListener( true), false);
				xhr.addEventListener( "progress", progressListener( false), false);
			}
			return xhr;
		};

		jqXHR = _ajax.call( this, url, options);

			// delegate all jqXHR promise methods to our deferred
		for( var method in deferred.promise()) {
			jqXHR[ method]( deferred[ method]);
		}
		jqXHR.progress = deferred.progress;

			// overwrite the jqXHR promise methods with our promise and return the patched jqXHR
		return jqXHR;
	};

		/**
		 * jQuery.upload( url [, data] [, success(data, textStatus, jqXHR)] [, dataType] )
		 *
		 * @param url
		 *         A string containing the URL to which the request is sent.
		 * @param data
		 *         A map or string that is sent to the server with the request.
		 * @param success(data, textStatus, jqXHR)
		 *         A callback function that is executed if the request succeeds.
		 * @param dataType
		 *         The type of data expected from the server. Default: Intelligent Guess (xml, json, script, text, html).
		 *
		 * This is a shorthand Ajax function, which is equivalent to:
		 * .ajax({
		 *		processData	: false,
		 *		contentType	: false,
		 *		type		: 'POST',
		 *		url			: url,
		 *		data		: data,
		 *		success		: callback,
		 *		dataType	: type
		 *	});
		 *
		 * @return jqXHR
		 */
	$.upload = function( url, data, callback, type) {
			// shift arguments if data argument was omitted
		if ( jQuery.isFunction( data ) ) {
			type = type || callback;
			callback = data;
			data = undefined;
		}

		return $.ajax({
			/*
			 * processData and contentType must be false to prevent jQuery
			 * setting its own defaults ... which would result in nonsense
			 */
			processData	: false,
			contentType	: false,
			type		: 'POST',
			url			: url,
			data		: data,
			success		: callback,
			dataType	: type
		});
	};
})( jQuery);

JUCI.app
.controller("SettingsUpgradeCtrl", function($scope, $config, $uci, $rpc, gettext){
	$scope.sessionID = $rpc.$sid();
	$scope.uploadFilename = "/tmp/uploads/firmware.bin";
	$scope.usbFileName = "()"; 
	
	$scope.config = $config; 
	
	function upgradeStart(path){
		$scope.error = ""; 
		$scope.progress = 'progress'; 
		console.log("Trying to upgrade from "+path); 
		/*$rpc.luci2.system.upgrade_test({"path": path}).done(function(result){
			if(result.stderr){
				$scope.error = "Upgrade test has failed: "+result.stderr; 
				$scope.$apply(); 
				return; 
			}*/
			$rpc.luci2.system.upgrade_start({"path": path}).done(function(result){
				if(result && result.stderr) {
					$scope.error = gettext("Upgrade process failed") + ": "+result.stderr; 
				} else {
					$scope.message = gettext("Upgrade process has started. The web gui will not be available until the process has finished and the box has restarted!");
					JUCI.interval("upgrade", 1000, function(done){
						$rpc.session.access().done(function(){
							// it will not succeed anymore because box is rebooting
						}).fail(function(result){
							if(result.code && result.code == -32002) { // access denied error. We will get it when it boots up again. 
								window.location.reload(); 
							}
						}).always(function(){
							done(); 
						}); 
					}); 
				}; 
				$scope.$apply();  
			}).fail(function(response){
				$scope.error = gettext("Upgrade process failed") + "! "+JSON.stringify(result||"");
				$scope.$apply();  
			});
		/*}).fail(function(result){
			$scope.error = gettext("Upgrade test has failed") + ": "+result.stderr; 
			$scope.$apply(); 
		}); */
	}
	
	/*$uci.sync("system").done(function(){
		if($uci.system.upgrade && $uci.system.upgrade.fw_upload_path.value){
			$scope.uploadFilename = $uci.system.upgrade.fw_upload_path.value; 
			console.log("Using upload path from config: "+$scope.uploadFilename); 
		}
	});*/ 
	
	$scope.onCheckOnline = function(){
		$rpc.luci2.system.upgrade_check({type: "online"}).done(function(response){
			if(response.stdout) $scope.onlineUpgrade = response.stdout.replace("\n", ""); 
			if(response.stderr) $scope.$emit("error", "Online upgrade check failed: "+response.stderr); 
			$scope.$apply(); 
		}); 
	} 
	$scope.onUpgradeOnline = function(){
		upgradeStart($scope.onlineUpgrade); 
	}
	
	$scope.onCheckUSB = function(){
		$rpc.luci2.system.upgrade_check({type: "usb"}).done(function(response){
			if(response.stdout) $scope.usbUpgrade = response.stdout.replace("\n", ""); 
			if(response.stderr) $scope.$emit("error", "USB upgrade check failed: "+response.stderr); 
			$scope.$apply(); 
		});
	}
	$scope.onUpgradeUSB = function(){
		upgradeStart($scope.usbUpgrade); 
	}
	
	$scope.onCheckUSB(); 
	$scope.onCheckOnline(); 
	
	$scope.onUploadComplete = function(result){
		console.log("Upload completed: "+JSON.stringify(result)); 
	}
	$scope.onUploadUpgrade = function(){
		$scope.showUpgradeStatus = 1; 
		$scope.message = "Uploading..."; 
		$scope.progress = 'uploading'; 
		$("#postiframe").bind("load", function(){
			var json = $(this).contents().text(); 
			var obj = {}; 
			try {
				obj = JSON.parse(json); 
			} catch(e){
				$scope.error = "The server returned an error ("+JSON.stringify(json)+")";
				$scope.progress = 'completed'; 
				$scope.$apply();
				//return;   
			}
			
			upgradeStart(); 
			
			$(this).unbind("load"); 
		}); 
		$("form[name='uploadForm']").submit();
	}
	$scope.onDismissModal = function(){
		$scope.showUpgradeStatus = 0; 
	}
}); 
