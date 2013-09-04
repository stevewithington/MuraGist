/**
* 
* This file is part of MuraGist
*
* Copyright 2013 Stephen J. Withington, Jr.
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component accessors=true extends='mura.cfobject' output=false {

	property name='$';

	include '../plugin/settings.cfm';

	public any function init(required struct $) {
		set$(arguments.$);
		return this;
	}

	/* 
	* CONFIGURED DISPLAY OBJECTS
	* --------------------------------------------------------------------- */

	// This method will be called by dspConfiguredGist()

	public any function dspGist(string gistID='', string gistFilename='') {
		var $ = StructKeyExists(arguments, '$') ? arguments.$ : get$();
		//var gistService = $.gistService;
		//gist = gistService.getGistScript(id=arguments.gistID, file=arguments.gistFilename);
		//return Len(gist) ? '<div class="gist-wrapper">' & gist & '</div>' : '';
		return '';
	}

	public any function dspConfiguredGist(required struct $) {
		var local = {};
		set$(arguments.$);

		local.params = arguments.$.event('objectParams');

		local.defaultParams = { 
			gistID = ''
			, gistDescription = ''
			, gistPublic = true
			, gistFiles = {}
		};

		StructAppend(local.params, local.defaultParams, false);

		return dspGist(argumentCollection=local.params);
	}

	// public any function getGistBean(
	// 	string id=''
	// 	, string description=''
	// 	, boolean public=true
	// 	, struct files={}
	// ) {
	// 	return new lib.gist.gistBean(argumentCollection=arguments);
	// }

}