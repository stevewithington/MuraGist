#MuraGist

This is a [Mura CMS](http://getmura.com) plugin that enables users to create, manage and display [Gists](https://gist.github.com) within their content.

##Instructions

###Plugin Display Objects
There is one display object available:

#### Display Gist
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