<cfscript>
/**
* 
* This file is part of MuraGist
*
* Copyright 2013 Stephen J. Withington, Jr.
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/

	$ = StructKeyExists(session, 'siteid') ? 
		application.serviceFactory.getBean('$').init('session.siteid') : 
		application.serviceFactory.getBean('$').init('default');

	params = IsJSON($.event('params')) ? DeSerializeJSON($.event('params')) : {};

	defaultParams = {
		gistid = ''
	};
	
	StructAppend(params, defaultParams, false);
</cfscript>
<!---
<style type="text/css">
	#availableObjectParams dt { padding-top:1em; }
	#availableObjectParams dt.first { padding-top:0; }
</style>
--->
<cfoutput>

	<div id="availableObjectParams"	
		data-object="plugin" 
		data-name="gist" 
		data-objectid="#$.event('objectID')#">

		<div class="row-fluid">

			<!--- Gist ID --->
			<div class="control-group">
				<label for="size" class="control-label">Gist ID</label>
				<div class="controls">
					<input type="text" 
						name="gistid" 
						id="gistid" 
						class="objectParam span12" 
						value="#params.gistid#">
				</div>
			</div>

		</div>

		<input type="hidden" name="configuredDTS" class="objectParam" value="#Now()#" />
		<input type="hidden" name="configuredBy" class="objectParam" value="#HTMLEditFormat($.currentUser('LName'))#, #HTMLEditFormat($.currentUser('FName'))#" />

	</div>

</cfoutput>