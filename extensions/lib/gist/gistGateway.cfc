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

	property name='apiUsername';
	property name='apiToken';
	property name='apiUrl';

	/**
	* @apiToken Log in to Github, go to Account Settings, select 'Applications' and create a 'Personal Access Token'
	*/
	public gistGateway function init(required string apiUsername, required string apiToken, string apiUrl='https://api.github.com') {
		setApiUsername(arguments.apiUsername)
		setApiToken(arguments.apiToken);
		setApiUrl(arguments.apiUrl);
		return this;
	}

	// --------------------------------------------------------------------------------------
	//	GISTS

	public any function getByID(required string id, boolean cached=true) {
		var endpoint = getApiUrl() & '/gists/' & arguments.id;
		var params = {
			url = { 'access_token' = getApiToken() }
		};
		var r = !arguments.cached
				|| !ArrayFindNoCase(CacheGetAllIDs(), arguments.id) 
				|| ( ArrayFindNoCase(CacheGetAllIDs(), arguments.id) && !IsJSON(CacheGet(arguments.id).Filecontent) )
					? ping(endpoint=endpoint, method='GET', params=params)
					: CacheGet(arguments.id);
		if ( IsDefined('r.Filecontent') && IsJSON(r.Filecontent) ) {
			CachePut(arguments.id, r, CreateTimeSpan(0,1,0,0));
		}
		return r;
	}

	public any function create(required struct files, boolean public=true, string description='') {
		var input = SerializeJSON({
			'public' = arguments.public
			, 'description' = arguments.description
			, 'files' = arguments.files
		});
		var endpoint = getApiUrl() & '/gists';
		var params = {
			url = { 'access_token' = getApiToken() }
			, body = { 'input' = input }
		};
		var r = ping(endpoint=endpoint, method='POST', params=params);
		return r;
	}

	public any function edit(required string id, required struct files, string description='') {
		var input = SerializeJSON({
			'description' = arguments.description
			, 'files' = arguments.files
		});
		var endpoint = getApiUrl() & '/gists/' & arguments.id; //arguments.gistBean.getID();
		var params = {
			url = { 'access_token' = getApiToken() }
			, body = { 'input' = input }
		};
		var r = ping(endpoint=endpoint, method='POST', params=params); // method='PATCH' throws an error, so using 'POST' instead
		CachePut(arguments.id, r, CreateTimeSpan(0,1,0,0));
		return r;
	}

	public any function delete(required string id) {
		var endpoint = getApiUrl() & '/gists/' & arguments.id;
		var params = {
			url = { 'access_token' = getApiToken() }
		};
		CacheRemove(arguments.id);
		return ping(endpoint=endpoint, method='DELETE', params=params);
	}

	public any function list() {
		var endpoint = getApiUrl() & '/users/' & getUsername() & '/gists';
		var params = {
			url = { 'access_token' = getApiToken() }
		};
		return ping(endpoint=endpoint, method='GET', params=params);
	}

	// --------------------------------------------------------------------------------------
	//	GITHUB STATUS

	public boolean function isConnected() {
		var isConnected = false;
		var endpoint = 'https://status.github.com/api/status.json';
		var response = ping(endpoint=endpoint, method='GET');
		try {
			var result = DeserializeJSON(response.filecontent);
			if ( StructKeyExists(result, 'status') && result.status == 'good' ) {
				isConnected = true;
			}
		} catch(any e) {}
		return isConnected;
	}

	// --------------------------------------------------------------------------------------
	//	HELPERS

	public any function ping(required string endpoint, string method='GET', struct params={}) {
		var response = {};
		var paramtype = '';
		var paramkey = '';
		var httpService = new http();

		httpService.setCharset('utf-8')
			.setMethod(arguments.method)
			.setURL(arguments.endpoint);

		if ( !StructIsEmpty(arguments.params) ) {
			for (paramtype in arguments.params) {
				for (paramkey in arguments.params[paramtype]) {
					httpService.addParam(type=paramtype,name=paramkey,value=arguments.params[paramtype][paramkey]);
				}
			}
		}

		return httpService.send().getPrefix();
	}

	// oauth
	public any function oAuth() {
		var params = {
			client_id = 'b8a31c5cdf7d3f23dd74'
			, redirect_uri = ''
			, scope = 'gist'
		}
	}

}