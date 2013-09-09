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

	property name='username';
	property name='password';
	property name='apiurl';

	public gistGateway function init(required string username, required string password, string apiURL='https://api.github.com') {
		setUsername(arguments.username);
		setPassword(arguments.password);
		setAPIURL(arguments.apiURL);
		return this;
	}

	// --------------------------------------------------------------------------------------
	//	GISTS

	public any function getByID(required string id, boolean cached=true) {
		var endpoint = getAPIURL() & '/gists/' & arguments.id;
		var r = !arguments.cached
				|| !ArrayFindNoCase(CacheGetAllIDs(), arguments.id) 
				|| ( ArrayFindNoCase(CacheGetAllIDs(), arguments.id) && !IsJSON(CacheGet(arguments.id).Filecontent) )
					? ping(endpoint=endpoint, method='GET')
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
		var endpoint = getAPIURL() & '/gists';
		var params = {
			input = { type='body', value=input }
		};
		var r = ping(endpoint=endpoint, method='POST', params=params);
		return r;
	}

	public any function edit(required string id, required struct files, string description='') {
		var input = SerializeJSON({
			'description' = arguments.description
			, 'files' = arguments.files
		});
		var endpoint = getAPIURL() & '/gists/' & arguments.id;
		var params = {
			input = { type='body', value=input }
		};
		var r = ping(endpoint=endpoint, method='POST', params=params); // method='PATCH' throws an error, so using 'POST' instead
		CachePut(arguments.id, r, CreateTimeSpan(0,1,0,0));
		return r;
	}

	public any function delete(required string id) {
		var endpoint = getAPIURL() & '/gists/' & arguments.id;
		CacheRemove(arguments.id);
		return ping(endpoint=endpoint, method='DELETE');
	}

	public any function list() {
		var endpoint = getAPIURL() & '/users/' & getUsername() & '/gists';
		return ping(endpoint=endpoint, method='GET');
	}

	// --------------------------------------------------------------------------------------
	//	HELPERS

	public any function ping(required string endpoint, string method='get', struct params={}) {
		var response = {};
		var i = '';
		var httpService = new http();
		httpService.setCharset('utf-8')
			.setUsername(getUsername())
			.setPassword(getPassword())
			.setMethod(arguments.method)
			.setURL(arguments.endpoint);
	

		if ( !StructIsEmpty(arguments.params) ) {
			for ( i in arguments.params ) {
				httpService.addParam(argumentCollection=arguments.params[i]);
			}
		}

		// writeDump(var=arguments, label='ARGS');
		// writeDump(var=httpService.getAttributes(), label='ATTRIBUTES');
		// writedump(var=httpService, abort=1);

		return httpService.send().getPrefix();
	}

}