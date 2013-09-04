/**
*
* @file  gist.cfc
* @author  Stephen J. Withington, Jr.
* @description Gist API Wrapper (http://developer.github.com/v3/gists/)
* @ratelimits Github limits authenticated requests to 5000 per hour. So, where possible, baked-in cfml caching is used. (https://learn.adobe.com/wiki/display/coldfusionen/Cache+functions)
*
*/
component output="false" accessors="true" {

	property name='username';
	property name='password';
	property name='apiurl';

	public gistManager function init(required string username, required string password, string apiURL='https://api.github.com') {
		setUsername(arguments.username);
		setPassword(arguments.password);
		setAPIURL(arguments.apiURL);
		return this;
	}

	// --------------------------------------------------------------------------------------
	//	HELPERS

	public boolean function isConnected() {
		var response = ping(getAPIURL());
		return IsDefined('response.Responseheader.Status');
	}

	public any function save(required string content, string filename='', boolean public=true, string description='', string id='') {
		var isGood = false;
		var result = {
			saved = false
			, initialResponse = {}
			, response = {}
			, id = ''
		};

		if ( isConnected() ) {

			if ( Len(arguments.id) ) {
				result.initialResponse = getByID(id=arguments.id, cached=false);
				isGood = isValidResponse(result.initialResponse);
			}

			switch(isGood) {
				case true :
					result.response = edit(
						id = arguments.id
						, content = arguments.content
						, filename = arguments.filename
						, description = arguments.description
					);
					break;
				default :
					result.response = create(
						content = arguments.content
						, filename = arguments.filename
						, public = arguments.public
						, description = arguments.description
					);
			}

			result.id = StructKeyExists(result.response, 'Filecontent') && IsJSON(result.response.Filecontent) 
				? deserializeJSON(result.response.Filecontent).id
				: '';
		}

		return result;
	}

	public any function getGistScript(required string id, string file='', boolean cached=true) {
		var gistURL = 'https://gist.github.com/' & arguments.id & '.js';
		var cacheID = '';
		var r = '';

		if ( !IsConnected() ) { return ''; }
		if ( Len(arguments.file) ) { gistURL &= '?file=' & arguments.file; }

		cacheID = Hash(gistURL);

		r = !arguments.cached
				|| !ArrayFindNoCase(CacheGetAllIDs(), cacheID) 
				|| (ArrayFindNoCase(CacheGetAllIDs(), cacheID) && !IsJSON(CacheGet(cacheID).Filecontent) )
					? ping(url=gistURL, method='GET')
					: CacheGet(cacheID);

		CachePut(cacheID, r, CreateTimeSpan(0,1,0,0));

		switch(isValidResponse(r)) {
			case true :
				return '<script src="#gistURL#"></script>';
				break;
			default :
				return '';
		}
	}

	public any function getGistFilecontent(struct response) {
		var r = arguments.response;
		switch(isValidResponse(r)) {
			case true :
				return IsJSON(r.Filecontent) ? DeSerializeJSON(r.Filecontent) : r.Filecontent;
				break;
			default :
				return {};
		}
	}

	public any function getGistStatusCode(struct response) {
		var r = arguments.response;

		switch (isValidResponse(r)) {
			case true :
				return r.Responseheader.Status_Code;
				break;
			default : 
				return 000;
		}
	}

	public any function isValidResponse(struct response) {
		var r = arguments.response;
		var isValid = false;

		try {
			switch (r.Responseheader.Status_Code) {
				case 200 : // OK ... gist found, gist updated, list found, etc.
					isValid = true;
					break;
				case 201 : // gist created, or gist forked
					isValid = true;
					break;
				case 204 : // gist deleted, or gist starred, unstarred
					isValid = true;
					break;
				case 401 : // bad credentials
					break;
				case 403 : // potentially several different issues such as too many login attempts
					break;
				case 404 : // gist not found
					break;
				default : // unknown status code
			}
		} catch(any e) {
			// any other errors probably means user is not connected to Internet
		}

		return isValid;
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
		CachePut(arguments.id, r, CreateTimeSpan(0,1,0,0));
		return r;
	}

	public any function create(required string content, string filename='', boolean public=true, string description='') {
		var input = SerializeJSON({
			'public' = '#arguments.public#'
			, 'description' = '#arguments.description#'
			, 'files' = {
				'#arguments.filename#' = { 
					'content' = '#arguments.content#' 
				}
			}
		});

		var url = getAPIURL() & '/gists';
		var params = {
			input = { type='body', value=input }
		};
		return ping(url=url, method='POST', params=params);
	}

	public any function edit(required string id, required string content, string filename='', string description='') {
		var input = SerializeJSON({
			'description' = '#arguments.description#'
			, 'files' = {
				'#arguments.filename#' = { 
					'content' = '#arguments.content#' 
				}
			}
		});

		var url = getAPIURL() & '/gists/' & arguments.id;
		var params = {
			input = { type='body', value=input }
		};
		CacheRemove(arguments.id);
		// method='PATCH' throws an error, so using 'POST' instead
		return ping(url=url, method='POST', params=params);
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
	//	PRIVATE

	private any function ping(required string url, string method='get', struct params={}, boolean useCredentials=true) {
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