<cfscript>
/**
* 
* This file is part of MuraGist
*
* Copyright 2015 Stephen J. Withington, Jr. <http://www.stephenwithington.com>
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
		, gistfilename = ''
		, gistdisplaymessage = true
	};
	
	StructAppend(params, defaultParams, false);
</cfscript>
<cfoutput>

	<div id="availableObjectParams"	
		data-object="plugin" 
		data-name="gist" 
		data-objectid="#$.event('objectID')#">

		<div class="row-fluid">

			<!--- Gist ID --->
			<div class="control-group">
				<label for="gistid" class="control-label">Gist ID</label>
				<div class="controls">
					<input type="text" 
						name="gistid" 
						id="gistid" 
						class="objectParam span12" 
						value="#params.gistid#">
				</div>
			</div>

			<!--- Gist Filename --->
			<div class="control-group">
				<label for="gistfilename" class="control-label">Gist Filename (optional)</label>
				<div class="controls">
					<input type="text" 
						name="gistfilename" 
						id="gistfilename" 
						class="objectParam span12" 
						value="#params.gistfilename#">
				</div>
				<p>Some Gists have more than one file associated with it. If you wish to display a specific file, enter the <em>exact</em> filename, or else all files associated with the Gist will be rendered.</p>
			</div>

			<!--- Display Message? --->
			<div class="control-group">
				<label for="gistdisplaymessage" class="control-label">Display Message?</label>
				<p>If a Gist doesn't exist, do you want to display a message? If 'No,' then nothing will be displayed.</p>
				<div class="radio inline">
					<input type="radio" name="gistdisplaymessage" id="displayYes" class="objectParam" value="1" <cfif YesNoFormat(params.gistdisplaymessage)>checked="checked"</cfif>>
					<label for="displayYes">Yes</label>
				</div>
				<div class="radio inline">
					<input type="radio" name="gistdisplaymessage" id="displayNo" class="objectParam" value="0" <cfif !YesNoFormat(params.gistdisplaymessage)>checked="checked"</cfif>>
					<label for="displayNo">No</label>
				</div>
			</div>

		</div>

		<input type="hidden" name="configuredDTS" class="objectParam" value="#Now()#" />
		<input type="hidden" name="configuredBy" class="objectParam" value="#HTMLEditFormat($.currentUser('LName'))#, #HTMLEditFormat($.currentUser('FName'))#" />

	</div>

</cfoutput>