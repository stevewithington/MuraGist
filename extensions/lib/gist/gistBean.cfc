/**
*
* @file  gistBean.cfc
* @author  Stephen J. Withington, Jr. <http://www.stephenwithington.com>
*
*/
component output="false" accessors="true" {

	property name='id' default='';
	property name='content' default='';
	property name='files' default={};
	property name='public' default=true;
	property name='description' default='';

	/**
	* @files { 'filename.ext': {'content': 'String of contents'} }
	*/
	public gistBean function init(
		string id=''
		, string content=''
		, boolean public=true
		, struct files={}
	) {
		setID(arguments.id);
		setContent(arguments.content);
		setPublic(arguments.public);
		setDescription(arguments.description);
		setFilename(arguments.filename);
		setFiles(arguments.files);
		return this;
	}

}