/**
* 
* This file is part of MuraGist
*
* Copyright 2013 Stephen J. Withington, Jr. <http://www.stephenwithington.com>
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component output="false" accessors="true" extends="mura.plugin.pluginGenericEventHandler" {

	property name='$' hint='mura scope';
	property name='username';
	property name='password';
	property name='muraGistManager';

	include '../plugin/settings.cfm';

	public any function onApplicationLoad($) {
		var tp = arguments.$.initTracePoint('MuraGist.extensions.eventHandler.onApplicationLoad');
		variables.pluginConfig.addEventHandler(this);
		arguments.$.commitTracePoint(tp);
		set$(arguments.$);
	}

	public any function onSiteRequestStart($) {
		var tp = arguments.$.initTracePoint('MuraGist.extensions.eventHandler.onBeforeContentSave');
		var contentRenderer = new contentRenderer(arguments.$);
		var muraGistManager = getMuraGistManager(arguments.$);
		arguments.$.setCustomMuraScopeKey(variables.settings.package, contentRenderer);
		arguments.$.setCustomMuraScopeKey('muraGistManager', muraGistManager);
		arguments.$.setCustomMuraScopeKey('muraGistEventHandler', this);

		// enable $.dspGist()
		arguments.$.getContentRenderer().injectMethod(
			'dspGist'
			, contentRenderer.dspGist
		);

		arguments.$.commitTracePoint(tp);
		set$(arguments.$);
	}

	public any function onRenderEnd($) {
		var tp = arguments.$.initTracePoint('MuraGist.extensions.eventHandler.onRenderEnd');
		var body = arguments.$.event('__MuraResponse__');
		var regex = '(?i)(<pre[^>]+>).+?(</pre>)';
		var gists = reFindMatches(regex, body); // array of code blocks wrapped with <pre> tags
		var gist = '';
		var originalGist = '';
		var xml = '';
		var attrs = '';
		var gistID = '';
		var gistScript = '';
		var gistFilename = '';
		var defaultGistFilename = Len(arguments.$.siteConfig('gistFilename')) ? arguments.$.siteConfig('gistFilename') : pluginConfig.getSetting('gistFilename');
		var muraGistManager = getMuraGistManager(arguments.$);

		for ( gist in gists ) {
			originalGist = gist;
			gist = ReplaceNoCase(gist,'&nbsp;',' ','ALL'); // XML does not support the &nbsp entity

			try {
				xml = XMLParse(gist);
			} catch (any e) {
				break; // bad gist
			}

			attrs = xml.XmlRoot.XmlAttributes;

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
		arguments.$.commitTracePoint(tp);
		set$(arguments.$);
	}

	public any function onBeforeContentSave($) {
		var tp = arguments.$.initTracePoint('MuraGist.extensions.eventHandler.onBeforeContentSave');
		var muraGistManager = getMuraGistManager(arguments.$);
		var errors = {};
		var error = '';
		var debug = arguments.$.globalConfig('debuggingenabled') == true ? true : false;
		var newBean = arguments.$.event('newBean');
		var oldBean = arguments.$.event('contentBean');
		var body = newBean.getBody();
		var gist = '';
		var regex = '(?i)(<pre[^>]+>).+?(</pre>)';
		var gists = reFindMatches(regex, body); // array of code blocks wrapped with <pre> tags
		var originalGist = '';
		var newGist = '';
		var xml = '';
		var attrs = '';
		var defaultGistFilename = Len(arguments.$.siteConfig('gistFilename')) ? arguments.$.siteConfig('gistFilename') : pluginConfig.getSetting('gistFilename');
		var defaultGistPublic = 1;
		var defaultGistDescription = '';
		var result = { id='', saved=false };
		var gistBean = '';
		var gistBeanArgs = {};
		var gistID = '';
		var gistFilenames = [];
		var gistFilename = '';
		var gistContent = '';
		var idx = 0;

		for ( gist in gists ) {
			originalGist = gist;
			gist = ReplaceNoCase(gist,'&nbsp;',' ','ALL'); // XML does not support the &nbsp entity

			try {
				xml = XMLParse(gist);
			} catch (any e) {
				break; // bad gist
			}

			attrs = xml.XmlRoot.XmlAttributes;

			if ( StructKeyExists(attrs, 'class') && ListFindNoCase(attrs.class, 'gist', ' ') ) {
				idx++;

				// Filenames must be unique for each file under a Gist
				gistFilename = StructKeyExists(attrs, 'data-gistfilename') && Len(attrs['data-gistfilename']) ? attrs['data-gistfilename'] : defaultGistFilename;
				if ( ArrayFind(gistFilenames, gistFilename) ) {
					gistFilename = ReFindNoCase('\.', gistFilename) 
						? ListFirst(gistFilename, '.', false) & idx & '.' & ListLast(gistFilename, '.', false)
						: gistFilename & idx;
				}
				ArrayAppend(gistFilenames, gistFilename);

				gistContent = Len(Trim(xml.XmlRoot.XmlText)) ? Trim(xml.XmlRoot.XmlText) : '';

				gistBeanArgs = {
					'id': StructKeyExists(attrs, 'data-gistid') && Len(attrs['data-gistid']) ? attrs['data-gistid'] : gistID
					, 'public' = StructKeyExists(attrs, 'data-gistpublic') ? attrs['data-gistpublic'] : defaultGistPublic
					, 'description' = StructKeyExists(attrs, 'data-gistdescription') && Len(attrs['data-gistdescription']) ? attrs['data-gistdescription'] : defaultGistDescription
					, 'files' = {
						'#gistFilename#' = {
							'content' = Len(Trim(gistContent)) ? gistContent : JavaCast('null', '')
						}
					}
					, 'gistManager' = muraGistManager
				};

				gistBean = new lib.gist.gistBean(argumentCollection=gistBeanArgs);

				try {
					result = gistBean.save();
				} catch(any e) {
					StructAppend(errors, {
						'e#StructCount(errors)+1#': 'An error occured while attempting to save a Gist. In other words, it is not possible to save your Gist(s) at this time.'
						, 'e#StructCount(errors)+2#': 'Error Message: #e.message#'
					});
				}

				if ( result.saved || !Len(gistContent) ) {
					newGist = Len(gistContent) ? '<pre class="#attrs.class#" data-gistid="#result.id#" data-gistfilename="#Trim(HTMLEditFormat(gistFilename))#" data-gistdescription="#Trim(HTMLEditFormat(gistBeanArgs.description))#">#Trim(HTMLEditFormat(gistContent))#</pre>' : '';
					body = ReplaceNoCase(body, originalGist, newGist);
					gistID = result.id;
				}
			}
		}

		if ( !StructIsEmpty(errors) ) {
			for ( error in errors ) {
				arguments.$.event('contentBean').getErrors()[error] = errors[error];
			}
		} else {
			newBean.setBody(body);
		}

		arguments.$.commitTracePoint(tp);
		set$(arguments.$);
	}

	// --------------------------------------------------------------------------------------
	//	HELPERS

	public any function getMuraGistManager($=get$()) {
		var tp = arguments.$.initTracePoint('MuraGist.extensions.eventHandler.getMuraGistManager');
		var username = Len(arguments.$.siteConfig('gistUsername')) ? arguments.$.siteConfig('gistUsername') : pluginConfig.getSetting('gistUsername');
		var token = Len(arguments.$.siteConfig('gistToken')) ? arguments.$.siteConfig('gistToken') : pluginConfig.getSetting('gistToken');
		var muraGistGateway = new lib.gist.gistGateway(apiUsername=username, apiToken=token);
		var muraGistManager = new lib.gist.gistManager(muraGistGateway);
		arguments.$.commitTracePoint(tp);
		return muraGistManager;
	}

	public array function reFindMatches(required string regex, required string str) {
		var start = 1;
		var result = [];
		var matches	= [];
		var match = '';
		do {
			matches = ReFind(arguments.regex, arguments.str, start, true);
			if ( matches.pos[1] ) {
				match = matches.len[1] ? Mid(arguments.str, matches.pos[1], matches.len[1]) : '';
				ArrayAppend(result, match);
				start = matches.pos[1] + matches.len[1];
			}
		} while(matches.pos[1]);
		return result;
	}

}