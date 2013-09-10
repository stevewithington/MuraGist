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
	.code {font-family: Courier New, monospace;}
</style>
<cfsavecontent variable="body"><cfoutput>
<div id="bodyWrap">
	<h1>#HTMLEditFormat(pluginConfig.getName())#</h1>

	<p class="intro">This is a <a href="http://getmura.com">Mura CMS</a> plugin that enables users to create, manage and display <a href="https://gist.github.com">Gists</a> within their content.</p>

	<h2>Instructions</h2>

	<h3>Usage</h3>
	<p>From the 'Content' area of any content item in Mura CMS, you can easily create/manage a Gist by wrapping your text with <span class="code">&lt;pre&gt;</span> tags with a class of <span class="code">gist</span>. The <span class="code">class</span> attribute may contain multiple class names, if desired. For example:</p>

<pre class="code">&lt;pre class=&quot;gist someOtherClass&quot;&gt;
	var x=1;
&lt;/pre&gt;</pre>

	<p>Each content item in Mura is considered a <strong>Gist</strong>. A Gist can have one or more <span class="code">files</span>. This means you can have more than one code block within our content area. Optionally, you can specify a unique filename for each code block using the <span class="code">data-gistfilename</span> attribute. For example:</p>

<pre class="code">&lt;pre class=&quot;gist&quot; data-gistfilename=&quot;myFile.js&quot;&gt;
	var x=1;
	var y=2;
&lt;/pre&gt;</pre>

	<p>The syntax highlighting will be determined by the file extension at the end of the filename. You can specify a default filename under the plugin's settings or at the site-level by going to **Site Config > Edit Site**, select the **Extended Attributes** tab, and enter a value in the **Default Gist Filename** field.</p>

	<p>As of Mura version 6.1, [google-code-prettify](https://code.google.com/p/google-code-prettify/) can be used as a fallback for when a Gist either doesn't exist, or the service is unavailable. To do this, you simply highlight a portion of text and select `Code` from the **Styles** select menu. Then, select the `Source` button and add `gist` to the list of class names. For example:</p>

<pre class="code">
&lt;pre class=&quot;prettyprint linenums gist&quot;&gt;
	var x=1;
&lt;/pre&gt;
</pre>

	<p>On the first, or primary Gist, you can also add a **Description** for the Gist by using the `data-gistdescription` attribute. For example:</p>

<pre class="code">
&lt;pre class=&quot;prettyprint linenums gist&quot; data-gistdescription=&quot;This is my description.&quot;&gt;
var x=1;
&lt;/pre&gt;
</pre>

	<p>Once the content item has been plublished, a `data-gistid` attribute is automatically added (along with the other optional attributes). If you edit the content item and select `Source`, you would see something similar to the following:</p>

<pre class="code">
&lt;pre class=&quot;prettyprint linenums gist&quot; 
	data-gistdescription=&quot;This is my description&quot; 
	data-gistfilename=&quot;file.cfm&quot; 
	data-gistid=&quot;6503760&quot;&gt;
	var x=1;
&lt;/pre&gt;
</pre>

	<p>If you simply wish to display an existing Gist in your code, then use one of the **Plugin Display Objects** options below.</p>

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
					<p><span class="code">string</span> The ID of the Gist you wish to display.</p>
				</td>
			</tr>
			<tr>
				<td class="code">gistFilename</td>
				<td>Optional</td>
				<td class="code">{empty string}</td>
				<td>
					<p><span class="code">string</span> Gists can have more than one file associated with it. If you wish to display a specific file, specify the filename here.</p>
				</td>
			</tr>
			<tr>
				<td class="code">gistDisplayMessage</td> 
				<td>Optional</td>
				<td class="code">true</td>
				<td>
					<p><span class="code">boolean</span> If a Gist doesn't exist, do you want to display a message? If <span class="code">false</span> then nothing will be displayed.</p>
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