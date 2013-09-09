/**
* 
* This file is part of MuraGist
*
* Copyright 2013 Stephen J. Withington, Jr. <http://www.stephenwithington.com>
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component output="false" accessors="true" extends="mura.cfobject" {

	property name='$';

	include '../plugin/settings.cfm';

	public any function init(required struct $) {
		set$(arguments.$);
		return this;
	}

	public any function dspGist(string gistID='', string gistFilename='', boolean displayMessage=true) {
		var muraGistManager = variables.$.muraGistManager;
		var gist = muraGistManager.getGistScript(id=arguments.gistID, file=arguments.gistFilename);
		return Len(gist) 
			? gist 
			: arguments.displayMessage
				? '<p class="notice">Gist ###arguments.gistID# could not be found. Maybe it no longer exists, or the Gist service is currently unavailable.</p>'
				: '';
	}

	/* 
	* CONFIGURABLE DISPLAY OBJECT(S)
	* --------------------------------------------------------------------- */
	public any function dspConfiguredGist($) {
		var params = arguments.$.event('objectParams');
		var defaultParams = { 
			gistID = ''
			, gistFilename = ''
		};
		StructAppend(local.params, local.defaultParams, false);
		variables.$ = arguments.$;
		return dspGist(argumentCollection=local.params);
	}

}