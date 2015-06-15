var express = require('express');
var app = express();
var JSON = require("JSON"); 
var fs = require("fs"); 
var request = require("request"); 

var bodyParser = require('body-parser')

var config = {
	ubus_uri: "http://192.168.1.1/ubus" // <-- your router uri
}; 

app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

app.use(express.static(__dirname + '/htdocs'));

var rpc_calls = {
	/*"luci2.ui.menu": function(params, next){
		var menu = {}; 
		// combine all menu files we have locally
		fs.readdir("share/menu.d", function(err, files){
			files.map(function(file){
				var obj = JSON.parse(fs.readFileSync("share/menu.d/"+file)); 
				Object.keys(obj).map(function(k){
					menu[k] = obj[k]; 
				});  
			}); 
			next({
				menu: menu
			}); 
		}); 
	}, */
	"local.features": function(params, next){
		next({"list": ["rpcforward"]}); 
	}, 
	"local.set_rpc_host": function(params, next){
		if(params.rpc_host) {
			config.ubus_uri = "http://"+params.rpc_host+"/ubus"; 
			console.log("Server: will forward all requests to "+config.ubus_uri); 
		}
		next({}); 
	}, 
	/*"session.access": function(params, next){
		next({
			"access-group": [ "a", "b" ] // just bogus access groups
		}); 
	}*/
}; 

// RPC end point
app.post('/ubus', function(req, res) {
  res.header('Content-Type', 'application/json');
  
  var data = req.body, err = null, rpcMethod;
  
	
	if (!err && data.jsonrpc !== '2.0') {
		onError({
			code: -32600,
			message: 'Bad Request. JSON RPC version is invalid or missing',
			data: null
		}, 400);
		return;
	}
	
	var name = data.params[1]+"."+data.params[2]; 
	if(name in rpc_calls){
		console.log("JSON_LOCAL: "+JSON.stringify(data)); 
	
		rpc_calls[name](data.params[3], function(resp){
			var json = JSON.stringify({
				jsonrpc: "2.0", 
				result: [0, resp]
			});
			console.log("JSON_RESP: "+json); 
			res.write(json); 
			res.end(); 
		}); 
	} else {
		console.log("JSON_CALL (-> "+config.ubus_uri+"): "+JSON.stringify(data)); 
		
		function sendResponse(body){
			var json = JSON.stringify(body); 
			console.log("JSON_RESP: "+json); 
			res.write(json); 
			res.end(); 
		}
		
		var timedOut = false; 
		var timeout = setTimeout(function(){
			var body = {
				jsonrpc: "2.0", 
				result: [1, "ETIMEOUT"]
			};
			timedOut = true; 
			sendResponse(body); 
		}, 5000); 
		
		request({ 
			url: config.ubus_uri,
			method: "POST",
			json: true,   // <--Very important!!!
			body: data
		}, function (error, response, body) {
			if(error){ 
				console.log("ERROR: "+error); 
				body = {
					jsonrpc: "2.0", 
					result: [1, String(error)]
				};
				//doLocalRPC(); 
			}
			clearTimeout(timeout); 
			if(!timedOut){
				sendResponse(body); 
			}
		});
		//console.log("Unknown RPC call "+name); 
		//res.end(); 
	}
	
  
/*
	console.log(JSON.stringify(data)); 
	
  */
});

var server = app.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;

	for(var i = 0; i < process.argv.length; i++){
		switch(process.argv[i]){
			case "-p": {
				var paths = process.argv[++i].split(";"); 
				paths.map(function(k){
					var url, path; 
					if(k.indexOf(":") >= 0){
						var parts = k.split(":"); 
						path = parts[1]; 
						url = parts[0]; 
					} else {
						url = k.split("/").pop(); 
						path = k; 
					}
					console.log("Adding extra plugin search path: "+path+" at "+url); 
					app.use(url, express.static(path + '/'));
				}); 
			} break; 
		}
	}
  console.log('Local server listening on http://%s:%s', host, port);
});

