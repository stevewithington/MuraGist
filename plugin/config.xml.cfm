<cfscript>
/**
* 
* This file is part of MuraGist
*
* Copyright 2013 Stephen J. Withington, Jr. <http://www.stephenwithington.com>
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
	include 'settings.cfm';
</cfscript>
<cfoutput>
	<plugin>
		<name>#variables.settings.pluginName#</name>
		<package>#variables.settings.package#</package>
		<directoryFormat>packageOnly</directoryFormat>
		<loadPriority>#variables.settings.loadPriority#</loadPriority>
		<version>#variables.settings.version#</version>
		<provider>#variables.settings.provider#</provider>
		<providerURL>#variables.settings.providerURL#</providerURL>
		<category>#variables.settings.category#</category>

		<settings>
			<setting>
				<name>gistUsername</name>
				<label>Github Account Username</label>
				<hint>You can override this setting on the Site Settings &gt; Extended Attribute Tab</hint>
				<type>text</type>
				<required>false</required>
				<validation>none</validation>
				<regex></regex>
				<message></message>
				<defaultvalue></defaultvalue>
				<optionlist></optionlist>
				<optionlabellist></optionlabellist>
			</setting>
			<setting>
				<name>gistToken</name>
				<label>Github Personal Access Token</label>
				<hint>Log in to Github, go to Account Settings, select 'Applications' and create a 'Personal Access Token'</hint>
				<type>text</type>
				<required>false</required>
				<validation>none</validation>
				<regex></regex>
				<message></message>
				<defaultvalue></defaultvalue>
				<optionlist></optionlist>
				<optionlabellist></optionlabellist>
			</setting>
			<setting>
				<name>gistFilename</name>
				<label>Default Gist Filename</label>
				<hint>This setting is used when your Gist does not contain a filename attribute. See instructions for more information.</hint>
				<type>text</type>
				<required>false</required>
				<validation>none</validation>
				<regex></regex>
				<message></message>
				<defaultvalue>file.cfm</defaultvalue>
				<optionlist></optionlist>
				<optionlabellist></optionlabellist>
			</setting>
		</settings>

		<eventHandlers>
			<eventHandler 
				event="onApplicationLoad" 
				component="extensions.eventHandler" 
				persist="false" />
		</eventHandlers>

		<displayobjects location="global">
			<displayobject
				name="Display Gist"  
				component="extensions.contentRenderer"
				displaymethod="dspConfiguredGist"
				configuratorJS="extensions/configurators/gist/configurator.js"
				configuratorInit="initMuraGistConfigurator"
				persist="false" />
		</displayobjects>

		<extensions>
			<extension type="Site">
				<attributeset name="MuraGist Options" container="Default">
					<attribute 
						name="gistUsername"
						label="Github Account Username"
						hint=""
						type="text"
						defaultValue=""
						required="false"
						validation=""
						regex=""
						message=""
						optionList=""
						optionLabelList="" />
					<attribute 
						name="gistToken"
						label="Github Personal Access Token"
						hint="Log in to Github, go to Account Settings, select 'Applications' and create a 'Personal Access Token'"
						type="text"
						defaultValue=""
						required="false"
						validation=""
						regex=""
						message=""
						optionList=""
						optionLabelList="" />
					<attribute 
						name="gistFilename"
						label="Default Gist Filename"
						hint=""
						type="text"
						defaultValue="file.cfm"
						required="false"
						validation=""
						regex=""
						message=""
						optionList=""
						optionLabelList="" />
				</attributeset>
			</extension>
		</extensions>
	</plugin>
</cfoutput>