LuCi Express (or just JuCi)
------------

This is a universal javascript client interface for broadband routers. It is an application written in javascript using angularjs, that communicates with your OpenWRT router over ubus calls (JSONRPC2.0).  

It includes a nodejs server which you can do for local testing and for forwarding jsonrpc calls to your router during testing (server.js). 

If offers you the following: 

* Extremely resource-efficient for your device - your router only needs to run the core functions (which can be written in C!) and the gui itself is running entirely inside the client's browser). You router only computes and sends the minimum information necessary. 
* Easy to work with - the code uses angular.js and html5, making it extremely easy to add new gui elements to the gui. 
* Full control and flexibility - yet many ready-made components: allowing you to pick yourself which level you want to develop on. There are no restrictions to the look and feel of your gui. 
* Dynamic theming - you can switch color themes at runtime. 
* Full language support - allowing for complete localization of your gui. Language file generation is even partially automatic (for html text). Also supporting dynamically changing language on page without having to reload the application. Also featuring quick debug mode for translations where you can see which strings are missing in currently used language pack. 

Getting started
---------------

To run local server for testing the gui: 

	sudo apt-get install nodejs npm 

In the main folder run: 

	npm install
	
This will install all nodejs dependencies. 

If you want to auto generate language "po" files, install grunt command line tool: 

	sudo npm install -g grunt-cli
	
No you can run the server using: 
	
	node server.js 
	
You may need to use 'nodejs' command instead of 'node' depending on your distro. 

Using UCI from the web console
---------------------

It is now possible to use UCI directly from your browser console. When you open your console you will have a global uci object defined in the application.

	uci.sync("wireless") // will sync the wireless table
	uci.sync(["wireless", "hosts"]) // will sync both wireless and hosts configs. 
	
	uci.wireless.wl0.channel.value = 1 // will set channel value to 1 
	
	uci.save() // will save the uci config
	
Note however that both uci.sync() and uci.save() are async methods so they return a promise. So if you need to do several operations in series then you need to do it like this: 

	uci.sync("wireless").done(function(){
		console.log("Channel: "+uci.wireless.wl0.channel.value); 
	}).fail(function(){
		console.log("Failed to sync tables!"); 
	}).always(function(){
		console.log("Done!"); 
	}); 
	
When you invoke sync() the uci code will load the specified configs into memory. The config types must be defined in uci.js file so that fields that are not present in the configs can be created with their default values. Please look in js/uci.js for details. This configuration may be moved somewhere else later. 

There are several ways to access config elements: 

	uci.wireless["@all"] // list of all sections in the wireless config
	uci.wireless["@wifi-device"] // list of only the wifi device sections
	uci.wireless.wl0 // access wl0 section by name (all sections that have a name can be accessed like this)
	uci.wireless.cfg012345 // access a section with an automatically created uci name. 
	
I have tried to mimic the command line uci tool here as much as possible. 

When you need to set a field value you need to use "value" member of the field. This is because we want to retain default and original value inside the field object so this is the only way to do this. This value field is defined with a setter and a getter so when you set a value that is different from the value retreived from your router then a field will be marked as dirty and will be sent to the router next time you call save(). 

	uci.wireless.wl0.channel.value = 1

JSONRPC service
---------------

Included in the source code is also a plugin for rpcd daemon on your OpenWRT router. It is designed to be the backend service that will handle your custom jsonrpc calls. You can hower run the application entirely on your local computer with no other dependencies but nodejs. All you have to do is implement the jsonrpc calls in your local service instead (see server.js). 

Getting to know the source code
-------------------------------

JuCi is a javascript application that gets loaded inside index.html file in htdocs directory. This file will be served as index page when you run the local server. The main application is found in js/app.js. This module in turn reads configuration and loads plugins found in the plugin folder. Each plugin contains a plugin.json file which tells the gui which javascript modules to load. 

There is one main javascript file and one html file for every page/widget/directive. In plugins you will usually not access angular directly but instead use $juci global variable to register controllers, directives and routes. This is because plugins are loaded dynamically when the application is already running and therefore we can not instantiate controllers in the usual way by using angular.module(..).controller(..) - use $juci.controller(..) instead. 

The menu system in the gui is actually created on the router side and retreived using luci2.ui.menu rpc call. This is based on the luci2 way of doing this task. It allows us to have dynamic menus that are automatically generated to match the functions of the router. 

License Notice
--------------

Project Author: Martin K. Schröder <mkschreder.uk@gmail.com>

Copyright (C) 2012-2013 Inteno Broadband Technology AB. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
version 2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
02110-1301 USA
