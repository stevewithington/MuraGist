/**
* 
* This file is part of MuraGist
*
* Copyright 2013 Stephen J. Withington, Jr.
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component accessors=true extends='mura.plugin.pluginGenericEventHandler' output=false {

	property name='$' hint='mura scope';
	property name='username';
	property name='password';
	property name='muraGistManager';

	include '../plugin/settings.cfm';

	public any function onApplicationLoad($) {
		variables.pluginConfig.addEventHandler(this);
		set$(arguments.$);
	}

	public any function onSiteRequestStart($) {
		var contentRenderer = new contentRenderer(arguments.$);
		var username = Len(arguments.$.siteConfig('gistUsername')) ? arguments.$.siteConfig('gistUsername') : pluginConfig.getSetting('gistUsername');
		var password = Len(arguments.$.siteConfig('gistPassword')) ? arguments.$.siteConfig('gistPassword') : pluginConfig.getSetting('gistPassword');
		var muraGistManager = new lib.gist.gistManager(username=username, password=password);

		arguments.$.setCustomMuraScopeKey(variables.settings.package, contentRenderer);
		arguments.$.setCustomMuraScopeKey('muraGistManager', muraGistManager);

		setMuraGistManager(muraGistManager);
		set$(arguments.$);
	}

	public any function onRenderEnd($) {
		var body = arguments.$.event('__MuraResponse__');
		var gists = ReMatch('(\<pre.*?\>).+?(\</pre\>)', body); // array of code blocks wrapped with <pre> tags
		var gist = '';
		var originalGist = '';
		var xml = '';
		var attrs = '';
		var gistID = '';
		var gistScript = '';
		var gistFilename = '';
		var defaultGistFilename = Len(arguments.$.siteConfig('gistFilename')) ? arguments.$.siteConfig('gistFilename') : pluginConfig.getSetting('gistFilename');
		var muraGistManager = getMuraGistManager();

		if ( muraGistManager.isConnected() ) {
			for ( gist in gists ) {
				originalGist = gist;
				gist = ReplaceNoCase(gist,'&nbsp;',' ','ALL'); // XML does not support the &nbsp entity

				try {
					xml = XMLParse(gist);
				} catch (any e) {
					break; // bad gist
				}

				attrs = xml.pre.XmlAttributes;

				if ( 
					StructKeyExists(attrs, 'class') 
					&& ListFindNoCase(attrs.class, 'gist', ' ') 
					&& StructKeyExists(attrs, 'data-gistid') 
					&& Len(attrs['data-gistid']) 
				) {
					gistID = attrs['data-gistid'];
					gistFilename = StructKeyExists(attrs, 'data-gistfilename') && Len(attrs['data-gistfilename'])
						? attrs['data-gistfilename'] 
						: defaultGistFilename;

					gistScript = muraGistManager.getGistScript(id=gistID, file=gistFilename);

					if ( Len(gistScript) ) {
						body = ReplaceNoCase(body, originalGist, gistScript);
					}
				}
			}
			arguments.$.event('__MuraResponse__', body);
		}
		set$(arguments.$);
	}

	public any function onBeforeContentSave($) {
		var username = Len(arguments.$.siteConfig('gistUsername')) ? arguments.$.siteConfig('gistUsername') : pluginConfig.getSetting('gistUsername');
		var password = Len(arguments.$.siteConfig('gistPassword')) ? arguments.$.siteConfig('gistPassword') : pluginConfig.getSetting('gistPassword');
		var muraGistManager = new lib.gist.gistManager(username=username, password=password);
		var errors = {};
		var error = '';
		var debug = arguments.$.globalConfig('debuggingenabled') == true ? true : false;
		var newBean = arguments.$.event('newBean');
		var oldBean = arguments.$.event('contentBean');
		var body = newBean.getBody();
		var gist = '';
		var gists = ReMatch('(\<pre.*?\>).+?(\</pre\>)', body); // array of code blocks wrapped with <pre> tags
		var originalGist = '';
		var newGist = '';
		var xml = '';
		var attrs = '';
		var defaultGistFilename = Len(arguments.$.siteConfig('gistFilename')) ? arguments.$.siteConfig('gistFilename') : pluginConfig.getSetting('gistFilename');
		var defaultGistPublic = 1;
		var result = { id = '' };
		var gistBean = '';
		var gistBeanArgs = {};
		var gistID = '';
		var gistFilenames = [];
		var gistFilename = '';
		var gistContent = '';
		var idx = 0;

		if ( !muraGistManager.isConnected() ) {
			StructAppend(errors, {'e#StructCount(errors)+1#': 'Connection Failure. Either github.com is down or you have no connection to the Internet. In other words, it is not possible to save your Gist at this time.'});
		} else {

			gistBeans = {};

			for ( gist in gists ) {
				originalGist = gist;
				gist = ReplaceNoCase(gist,'&nbsp;',' ','ALL'); // XML does not support the &nbsp entity

				try {
					xml = XMLParse(gist);
				} catch (any e) {
					break; // bad gist
				}

				attrs = xml.pre.XmlAttributes;

				if ( StructKeyExists(attrs, 'class') && ListFindNoCase(attrs.class, 'gist', ' ') ) {
					idx++;

					// Filenames must be unique for each file under a Gist
					gistFilename = StructKeyExists(attrs, 'data-gistfilename') && Len(attrs['data-gistfilename']) ? attrs['data-gistfilename'] : defaultGistFilename;
					if ( ArrayFind(gistFilenames, gistFilename) ) {
						gistFilename = ListFirst(gistFilename, '.', false) & idx & '.' & ListLast(gistFilename, '.', false);
					}
					ArrayAppend(gistFilenames, gistFilename);

					gistContent = Len(Trim(xml.pre.XmlText)) ? Trim(xml.pre.XmlText) : '';

					gistBeanArgs = {
						'id': StructKeyExists(attrs, 'data-gistid') && Len(attrs['data-gistid']) ? attrs['data-gistid'] : gistID
						, 'public' = StructKeyExists(attrs, 'data-gistpublic') ? attrs['data-gistpublic'] : defaultGistPublic
						, 'description' = StructKeyExists(attrs, 'data-gistdescription') ? attrs['data-gistdescription'] : ''
						, 'files' = {
							'#gistFilename#' = {
								'content' = gistContent
							}
						}
						, 'gistManager' = muraGistManager
					};

					gistBean = new lib.gist.gistBean(argumentCollection=gistBeanArgs);

					try {
						result = gistBean.save();
					} catch(any e) {
						StructAppend(errors, {
							'e#StructCount(errors)+1#': 'An error occured while attempting to save a Gist.'
							, 'e#StructCount(errors)+2#': 'Error Message: #e.message#'
							, 'e#StructCount(errors)+3#': 'Error Detail: #e.detail#'
						});
					}

					if ( Len(result.id) ) {
						newGist = '<pre class="#attrs.class#" data-gistid="#result.id#" data-gistfilename="#gistFilename#" data-gistdescription="#gistBeanArgs.description#">#Trim(HTMLEditFormat(gistContent))#</pre>';
						body = ReplaceNoCase(body, originalGist, newGist);
						gistID = result.id;
					}
				}
			}

			// now create/update the Gist(s)



		}

		if ( !StructIsEmpty(errors) ) {
			for ( error in errors ) {
				arguments.$.event('contentBean').getErrors()[error] = errors[error];
			}
		} else {
			newBean.setBody(body);
		}

		set$(arguments.$);
	}


	// --------------------------------------------------------------------------------------
	//	HELPERS

	public any function getGistBean(
		string id=''
		, string content=''
		, boolean public=true
		, struct files={}
	) {
		return new lib.gist.gistBean(argumentCollection=arguments);
	}

}