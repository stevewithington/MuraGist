/**
* 
* This file is part of MuraGist
*
* Copyright 2015 Stephen J. Withington, Jr. <http://www.stephenwithington.com>
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component output="false" accessors="true" {

	property name='id' default='';
	property name='description' default='';
	property name='public' default=true;
	property name='files' default='';
	property name='gistManager' default='';

	/**
	* @files { 'filename.ext': {'content': 'String of contents'} }
	*/
	public gistBean function init(
		string id=''
		, string description=''
		, boolean public=true
		, struct files={}
		, any gistManager=''
	) {
		setID(arguments.id);
		setDescription(arguments.description);
		setPublic(arguments.public);
		setFiles(arguments.files);
		setGistManager(arguments.gistManager);
		return this;
	}

	public struct function getAllValues() {
		return getProperties();
	}

	public struct function getProperties() {
		var properties = {};
		var data = getMetaData(this).properties;
		for ( var i in data ) {
			properties['#i.name#'] = Evaluate('get#i.name#()');
		}
		return properties;
	}

	public any function save() {
		return getGistManager().save(this);
	}

}