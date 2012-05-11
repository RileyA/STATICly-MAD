package cgs.server.logging.requests
{
	import flash.net.URLVariables;

	public interface IServerRequest
	{
		/**
		 * Get the URL for the server request. With all parameters.
		 */
		function get url():String;
		
		/**
		 * Get the URL without any URL variables added.
		 */
		function get baseURL():String;
		
		function get urlVariables():URLVariables
		
		function get callback():Function;
		
		function get extraData():*;
		
		function get dataFormat():String;
		
		function get isPOST():Boolean;
		
		function get isGET():Boolean;
		
		function get method():String;
		
		function get responseClass():Class;
	}
}