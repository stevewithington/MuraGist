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
</cfscript>
<style type="text/css">
	#bodyWrap p.intro {font-size:1.25em;}
	#bodyWrap h3{padding-top:1em;}
	#bodyWrap ul{padding:0 0.75em 1em;margin:0 0.75em;}
</style>
<cfsavecontent variable="body"><cfoutput>
<div id="bodyWrap">
	<h1>#HTMLEditFormat(pluginConfig.getName())#</h1>

	<p class="intro">This is a <a href="http://getmura.com">Mura CMS</a> plugin that enables easy interaction with <a href="https://gist.github.com">Gists.</a></p>

	<h2>Key Features</h2>
	<ul>
		<li>Display Objects</li>
		<li>Configurable Display Objects</li>
		<li>Create &amp; Manage Gists</li>
	</ul>

	<h2>Instructions</h2>

	<h3>Plugin Display Objects</h3>
	<p>There is one display object available:</p>

	<ul>
		<li><strong>Display Gist</strong>
			<ol>
				<li>Go to the <strong>Edit Content</strong> screen of a content item</li>
				<li>Select the <strong>Layout &amp; Objects</strong> tab</li>
				<li>Select <strong>Plugins</strong> from the Available Content Objects select menu</li>
				<li>Select <strong>MuraGist</strong> from the list of Plugins</li>
				<li>Select <strong>Display Gist</strong> and assign it to your desired display region (e.g., Left Column, Main Content, etc.)</li>
				<li>This should launch the <strong>MuraGist Configurator</strong> window</li>
				<li>Paste/Enter your Gist ID into the Gist ID form field</li>
				<li>Optionally paste/enter your desired Gist filename into the Gist Filename form field. (Some Gists have more than one file associated with it. If you wish to display a specific file, enter the filename, or else all files associated with the Gist will be rendered.)</li>
				<li>Click <strong>Save</strong></li>
				<li>Then, Publish your content and preview</li>
			</ol>
		</li>
	</ul>


	<h2>Designers / Developers</h2>
	<p>The 'Plugin Display Objects' may also be added directly onto your template or even dropped into a content region using <strong>[mura]</strong> tags.</p>

	<h3>Example Code</h3>

	<h4>Mura Tag Method</h4>
	<pre class="notice">[mura]$.dspGist(gistID='YourGistID')[/mura]</pre>

	<h4>CFML Method</h4>
	<pre class="notice">##$.dspGist(gistID='YourGistID')##</pre>

		<h4>Available Attributes</h4>
	<table class="table">
		<thead>
			<tr>
				<th>Attribute</th>
				<th>Req/Opt</th>
				<th>Default</th>
				<th>Description</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td class="code">gistID</td>
				<td>Required</td>
				<td class="code">&nbsp;</td>
				<td>
					<p>The ID of the Gist you wish to display.</p>
				</td>
			</tr>
			<tr>
				<td class="code">gistFilename</td>
				<td>Optional</td>
				<td class="code">{empty string}</td>
				<td>
					<p>Gists can have more than one file associated with it. If you wish to display a specific file, specify the filename here.</p>
				</td>
			</tr>
		</tbody>
	</table>

	<h2>Tested With</h2>
	<ul>
		<li>Mura CMS Core Version <strong>6.1+</strong></li>
		<li>Adobe ColdFusion <strong>10.0.9</strong></li>
		<li>Railo <strong>4.0.4</strong></li>
	</ul>

	<h2>Need help?</h2>
	<p>If you're running into an issue, please let me know at <a href="https://github.com/stevewithington/#HTMLEditFormat(pluginConfig.getPackage())#/issues">https://github.com/stevewithington/#HTMLEditFormat(pluginConfig.getPackage())#/issues</a> and I'll try to address it as soon as I can.</p>
	
	<p>Cheers!<br />
	<a href="http://stephenwithington.com">Steve Withington</a></p>
</div>
</cfoutput></cfsavecontent>
<cfoutput>
	#$.getBean('pluginManager').renderAdminTemplate(
		body = body
		, pageTitle = pluginConfig.getName()
		, jsLib = 'jquery'
		, jsLibLoaded = false
	)#
</cfoutput>