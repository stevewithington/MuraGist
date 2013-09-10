/**
* 
* This file is part of MuraGist
*
* Copyright 2013 Stephen J. Withington, Jr. <http://www.stephenwithington.com>
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
* 
* @description 	Gist API Wrapper <http://developer.github.com/v3/gists/>
* @ratelimits 	Github limits authenticated requests to 5000 per hour, so baked-in cfml caching is used in some areas.
*
*/
component output="false" accessors="true" {

	property name='gistGateway';

	public gistManager function init(required gistGateway) {
		setGistGateway(arguments.gistGateway);
		return this;
	}

	public any function save(required struct gistBean) {
		var gistExists = false;
		var result = {
			saved = false
			, initialResponse = {}
			, response = {}
			, id = ''
			, gistBean = arguments.gistBean
		};

		if ( Len(arguments.gistBean.getID()) ) {
			result.initialResponse = getGistGateway().getByID(id=arguments.gistBean.getID(), cached=false);
			gistExists = isValidResponse(result.initialResponse);
		}

		result.response = gistExists 
			? getGistGateway().edit(argumentCollection=arguments.gistBean.getAllValues()) 
			: getGistGateway().create(argumentCollection=arguments.gistBean.getAllValues());

		result.parsedJSON = StructKeyExists(result.response, 'Filecontent') && IsJSON(result.response.Filecontent) 
			? DeserializeJSON(result.response.Filecontent)
			: {};

		result.id = IsDefined('result.parsedJSON.id') 
			? result.parsedJSON.id 
			: '';

		result.saved = Len(result.id) 
			? true 
			: false;

		return result;
	}

	public any function getGistScript(required string id, string file='', boolean cached=true, boolean debug=false) {
		var gistURL = 'https://gist.github.com/' & arguments.id & '.js';
		var cacheID = '';
		var response = '';
		var str = '';

		if ( Len(arguments.file) ) { 
			gistURL &= '?file=' & arguments.file; 
		}

		cacheID = Hash(gistURL);

		try {
			response = !arguments.cached
					|| !ArrayFindNoCase(CacheGetAllIDs(), cacheID) 
					|| (ArrayFindNoCase(CacheGetAllIDs(), cacheID) && !IsJSON(CacheGet(cacheID).Filecontent) )
						? getGistGateway().ping(endpoint=gistURL, method='GET')
						: CacheGet(cacheID);
		} catch(any e) {
			if (arguments.debug) { 
				WriteDump(var=e, abort=1); 
			}
		}

		switch(isValidResponse(response)) {
			case true :
				CachePut(cacheID, response, CreateTimeSpan(0,1,0,0));
				str = '<script src="#gistURL#"></script>';
				break;
			default :
				break;
		}
		return str;
	}

	public boolean function isValidResponse(required any response) {
		var resp = arguments.response;
		var isValid = false;

		try {
			switch (resp.Responseheader.Status_Code) {
				case 200 : // OK ... gist found, gist updated, list found, etc.
					isValid = true;
					break;
				case 201 : // gist created, or gist forked
					isValid = true;
					break;
				case 204 : // gist deleted, or gist starred, unstarred
					isValid = true;
					break;
				case 401 : // bad credentials OR two-factor authentication required (not enabled for this plugin yet)
					break;
				case 403 : // potentially several different issues such as too many login attempts
					break;
				case 404 : // gist not found
					break;
				default : // unknown status code
					break;
			}
		} catch(any e) {
			// any other errors probably means user is not connected to Internet, or the response is an empty string
		}

		return isValid;
	}

}