/**
* 
* This file is part of MuraGist
*
* Copyright 2015 Stephen J. Withington, Jr. <http://www.stephenwithington.com>
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
function initMuraGistConfigurator(data) {

	initConfigurator(data,{
		url: '../plugins/MuraGist/extensions/configurators/gist/configurator.cfm'
		, pars: ''
		, title: 'Display Gist'
		, init: function(){}
		, destroy: function(){}
		, validate: function(){
			// simple js validation
			if ( !jQuery('#gistid').val() ) {
				var response = alert('Please enter a Gist ID');
				return false;
			}
			return true;
		}
	});

	return true;

};