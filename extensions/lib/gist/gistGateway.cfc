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

	public any function list() {
		var url = getAPIURL() & '/users/' & getUsername() & '/gists';
		return ping(url=url, method='GET');
	}

	public any function getByID(required string id, boolean cached=true) {
		var url = getAPIURL() & '/gists/' & arguments.id;
		var r = !arguments.cached
				|| !ArrayFindNoCase(CacheGetAllIDs(), arguments.id) 
				|| ( ArrayFindNoCase(CacheGetAllIDs(), arguments.id) && !IsJSON(CacheGet(arguments.id).Filecontent) )
					? ping(url=url, method='GET')
					: CacheGet(arguments.id);
		if ( IsDefine(r.Filecontent) && IsJSON(r.Filecontent) ) {
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
		var url = getAPIURL() & '/gists';
		var params = {
			input = { type='body', value=input }
		};
		var r = ping(url=url, method='POST', params=params);
		return r;
	}

	public any function edit(required string id, required struct files, string description='') {
		var input = SerializeJSON({
			'description' = arguments.description
			, 'files' = arguments.files
		});
		var url = getAPIURL() & '/gists/' & arguments.id; //arguments.gistBean.getID();
		var params = {
			input = { type='body', value=input }
		};
		var r = ping(url=url, method='POST', params=params); // method='PATCH' throws an error, so using 'POST' instead
		CachePut(arguments.id, r, CreateTimeSpan(0,1,0,0));
		return r;
	}

	public any function star(required string id) {
		var url = getAPIURL() & '/gists/' & arguments.id & '/star';
		return ping(url=url, method='PUT');
	}

	public any function unstar(required string id) {
		var url = getAPIURL() & '/gists/' & arguments.id & '/star';
		return ping(url=url, method='DELETE');
	}

	public any function starcheck(required string id) {
		var url = getAPIURL() & '/gists/' & arguments.id & '/star';
		return ping(url=url, method='GET');
	}

	public any function fork(required string id) {
		var url = getAPIURL() & '/gists/' & arguments.id & '/forks';
		return ping(url=url, method='POST');
	}

	public any function delete(required string id) {
		var url = getAPIURL() & '/gists/' & arguments.id;
		CacheRemove(arguments.id);
		return ping(url=url, method='DELETE');
	}

	// --------------------------------------------------------------------------------------
	//	GIST COMMENTS

	public any function listComments(required string gistid) {
		var url = getAPIURL() & '/gists/' & arguments.gistid & '/comments';
		return ping(url=url, method='GET');
	}

	public any function getCommentByID(required string gistid, required string id) {
		var url = getAPIURL() & '/gists/' & arguments.gistid & '/comments/' & arguments.id;
		var cacheID = Hash(arguments.gistid & '-' & arguments.id);
		var response = !ArrayFindNoCase(CacheGetAllIDs(), cacheID)
				? ping(url=url, method='GET')
				: CacheGet(cacheID);
		CachePut(cacheID, response, CreateTimeSpan(0,1,0,0));
		return response;
	}

	public any function createComment(required string gistid) {
		var url = getAPIURL() & '/gists/' & arguments.gistid & '/comments';
		return ping(url=url, method='POST');
	}

	public any function editComment(required string gistid, required string id) {
		var url = getAPIURL() & '/gists/' & arguments.gistid & '/comments/' & arguments.id;
		// method='PATCH' throws an error, so using 'POST' instead
		return ping(url=url, method='POST');
	}

	public any function deleteComment(required string gistid, required string id) {
		var url = getAPIURL() & '/gists/' & arguments.gistid & '/comments/' & arguments.id;
		return ping(url=url, method='DELETE');
	}

	// --------------------------------------------------------------------------------------
	//	HELPERS

	public any function ping(required string url, string method='get', struct params={}, boolean useCredentials=true) {
		var response = {};
		var i = '';
		var http = new http();
		http.setCharset('utf-8')
			.setMethod(arguments.method)
			.setURL(arguments.url);

		if ( arguments.useCredentials ) {
			http.setUsername(getUsername()).setPassword(getPassword());
		}

		if ( !StructIsEmpty(arguments.params) ) {
			for ( i in arguments.params ) {
				http.addParam(argumentCollection=arguments.params[i]);
			}
		}

		return http.send().getPrefix();
	}

}