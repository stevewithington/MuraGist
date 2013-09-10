#MuraGist

This is a [Mura CMS](http://getmura.com) plugin that enables users to create, manage and display [Gists](https://gist.github.com) within their content.

##Instructions

###Installation
1. Log in to Github, go to Account Settings, select **Applications** and create a **Personal Access Token** and copy the access token
2. Download a .zip of this project from https://github.com/stevewithington/MuraGist/archive/master.zip
3. Log in to Mura CMS as a Super Admin
4. Go to **Settings > Plugins**
5. Click **Choose File** and select the .zip file you downloaded from Github
6. Click **Deploy**
7. **Accept** the License Agreement
8. Enter your **Github Account Username**
9. Paste the Personal Access Token you created in step 1 into the **Github Personal Access Token** field
10. Select which site(s) you wish to enable the plugin for
11. Click **Update**

###Usage
From the **Content** area of any content item in Mura CMS, you can easily create/manage a Gist by wrapping your text with `<pre>` tags with a class of `gist`. The `class` attribute may contain multiple class names, if desired. For example:

```
<pre class="gist someOtherClass">
var x=1;
</pre>
```

Each content item in Mura is considered a **Gist**. A Gist may contain one or more `files`. This means you can have more than one code block within the content area. Optionally, you may also specify a unique filename for each code block using the `data-gistfilename` attribute. For example:

```
<pre class="gist" data-gistfilename="someFile.js">
function daysInMonth(iMonth, iYear) {
    return 32 - new Date(iYear, iMonth, 32).getDate();
}
</pre>

<pre class="gist" data-gistfilename="anotherFile.cfm">
<cfscript>
$ = IsDefined('session') && StructKeyExists(session, 'siteid') ?
	application.serviceFactory.getBean('$').init(session.siteid) :
	application.serviceFactory.getBean('$').init('default');
</cfscript>
</pre>
```

The syntax highlighting will be determined by the file extension at the end of the filename. You can specify the default filename under the plugin's settings or at the site-level under **Site Config > Edit Site**, select the **Extended Attributes** tab, and enter a value in the **Default Gist Filename** field.

As of Mura version 6.1, [google-code-prettify](https://code.google.com/p/google-code-prettify/) can be used as a fallback for when a Gist either doesn't exist, or the service is unavailable. To do this, you simply highlight a portion of text and select `Code` from the **Styles** select menu. Then, select the **Source** button from the editor toolbar and add `gist` to the list of class names. For example:

```
<pre class="prettyprint linenums gist">
var x=1;
</pre>
```

On the first, or primary Gist, you may also add a **Description** for the Gist by using the `data-gistdescription` attribute. For example:

```
<pre class="prettyprint linenums gist" data-gistdescription="This is my description.">
var x=1;
</pre>
```

Once the content item has been published, a `data-gistid` attribute is automatically added (*along with the other optional attributes*). If you edit the content item and select **Source**, you should see something similar to the following:

```
<pre class="prettyprint linenums gist" 
	data-gistdescription="This is my description" 
	data-gistfilename="file.cfm" 
	data-gistid="6503760">
var x=1;
</pre>
```

If you simply wish to display an existing Gist in your code, then use one of the **Plugin Display Objects** options below.

###Plugin Display Objects
There is one display object available:

####Display Gist
* Go to the **Edit Content** screen of a content item
* Select the **Layout &amp; Objects** tab
* Select **Plugins** from the Available Content Objects select menu
* Select **MuraGist** from the list of Plugins
* Select **Display Gist** and assign it to your desired display region (e.g., Left Column, Main Content, etc.)
* This should launch the **MuraGist Configurator** window
* Paste/Enter your Gist ID into the Gist ID form field
* Optionally paste/enter your desired Gist filename into the Gist Filename form field. (Some Gists have more than one file associated with it. If you wish to display a specific file, enter the filename, or else all files associated with the Gist will be rendered.)
* Click **Save**
* Then, Publish your content and preview

##Designers / Developers
The 'Plugin Display Objects' may also be added directly onto your template or even dropped into a content region using **[mura]** tags.

###Example Code

####Mura Tag Method
`[mura]$.dspGist(gistID='YourGistID')[/mura]`

####CFML Method
`#$.dspGist(gistID='YourGistID')#`

####Available Attributes

| Attribute 		| Req/Opt 	| Default 			| Description 								|
| ---				| ---		| ---				| ---										|
| `gistID`			| Required 	| 					| `string` The ID of the Gist you wish to display. 	|
| `gistFilename`	| Optional 	| `{empty string}` 	| `string` Gists can have more than one file associated with it. If you wish to display a specific file, specify the filename here. 	|
| `gistDisplayMessage` 	| Optional 	| `true` 			| `boolean` If a Gist either doesn't exist, do you want to display a message? If `false` then nothing will be displayed. |

##Tested With
* Mura CMS Core Version 6.1+
* Adobe ColdFusion 10.0.9
* Railo 4.1.1


##License
Copyright 2013 Stephen J. Withington, Jr. <http://www.stephenwithington.com>

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.