package cgs.server.logging.requests
{
	import cgs.server.logging.CGSServer;
	import cgs.server.logging.CGSServerConstants;
	import cgs.server.logging.GameServerData;
	
	import com.adobe.serialization.json.JSONEncoder;
	import com.hurlant.util.Base64;
	
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	
	public class ServerRequest extends CallbackRequest implements IServerRequest
	{
		public static const LOGGING_URL:int = 1;
		public static const AB_TESTING_URL:int = 2;
		public static const GENERAL_URL:int = 3;
		
		public var _generalURL:String;
		
		//Method called on the server.
		public var _method:String;
		
		//Class used to create a response object when the server responds.
		public var _responseClass:Class;
		
		//Data payload added to the server request.
		public var data:Object;
		
		//URL variables added to the request.
		public var params:Object;
		
		//Type of request made to the server.
		public var _dataFormat:String;
		
		//Extra data which can be stored as part of the request.
		protected var _extraData:*;
		
		protected var _urlType:int = LOGGING_URL;
		
		protected var _gameServerData:GameServerData;
		
		public function ServerRequest(method:String, callback:Function, data:Object, params:Object = null,
				extraData:* = null, responseClass:Class = null, requestType:String = URLLoaderDataFormat.TEXT, url:String = null, serverData:GameServerData = null)
		{
			super(callback);
			
			this._method = method != null ? method : "";
			this._responseClass = responseClass;
			this.data = data;
			this.params = params;
			this._dataFormat = requestType;
			_extraData = extraData;
			_generalURL = url;
			
			_gameServerData = serverData == null ? GameServerData.instance : serverData;
		}
		
		public function get responseClass():Class
		{
			return _responseClass;
		}
		
		public function get method():String
		{
			return _method;
		}
		
		public function set urlType(value:int):void
		{
			_urlType = value;
		}
		
		public function get isPOST():Boolean
		{
			return false;
		}
		
		public function get isGET():Boolean
		{
			return true;
		}
		
		public function get dataFormat():String
		{
			return _dataFormat;
		}
		
		public function get extraData():*
		{
			return _extraData;
		}
		
		public function get baseURL():String
		{
			var baseURL:String = "";
			if(_urlType == LOGGING_URL)
			{
				baseURL = _gameServerData.serverURL;
			}
			else if(_urlType == AB_TESTING_URL)
			{
				baseURL = _gameServerData.abTestingURL;
			}
			else if(_urlType == GENERAL_URL)
			{
				baseURL = _generalURL;
			}
			
			return baseURL + _method + "?";
		}
		
		public function get urlVariables():URLVariables
		{
			var variables:URLVariables = new URLVariables();
			var jsonDataString:String = "";
			if(data != null)
			{
				var dataEncoder:JSONEncoder = new JSONEncoder(data);
				jsonDataString = dataEncoder.getString();
				var includeData:String = jsonDataString;
				
				//Encode the data string based on the server props.
				if(_gameServerData.dataEncoding == GameServerData.BASE_64_ENCODING)
				{
					includeData = Base64.encode(jsonDataString);
				}
				
				variables.data = includeData;
			}
			
			if(_gameServerData.skeyHashVersion == GameServerData.DATA_SKEY_HASH)
			{
				variables.skey = _gameServerData.createSkeyHash(jsonDataString);
			}
			
			variables.de = _gameServerData.dataEncoding;
			
			//Add the URL variables to the URL.
			if(params != null)
			{
				for(var param:String in params)
				{
					variables.param = params[param];
				}
			}
			
			//Add latency variable to the request.
			if(_gameServerData.useDevelopmentServer)
			{
				variables.latency = CGSServerConstants.serverLatency;
			}
			
			//Add a noCache variable to the URL.
			variables.noCache = CGSServer.getTimeStamp();
			
			return variables;
		}
		
		/**
		 * Get url for the server request. This url includes all url variables.
		 */
		public function get url():String
		{
			var requestURL:String = baseURL;
			var hasParam:Boolean = false;
			
			//Add the data payload to the url.
			var jsonDataString:String = "";
			if(data != null)
			{
				var dataEncoder:JSONEncoder = new JSONEncoder(data);
				jsonDataString = dataEncoder.getString();
				var includeData:String = jsonDataString;
				
				//Encode the data string based on the server props.
				if(_gameServerData.dataEncoding == GameServerData.BASE_64_ENCODING)
				{
					includeData = Base64.encode(jsonDataString);
				}
				
				requestURL += "data=" + includeData;
				hasParam = true;
			}
			
			//Add the skey as a paramter if the data should be hashed with the skey.
			if(_gameServerData.skeyHashVersion == GameServerData.DATA_SKEY_HASH)
			{
				if(hasParam)
				{
					requestURL += "&";
				}
				requestURL += "skey=" + _gameServerData.createSkeyHash(jsonDataString);
				hasParam = true;
			}
			
			if(hasParam)
			{
				requestURL += "&";
			}
			requestURL += "de=" + _gameServerData.dataEncoding;
			hasParam = true;
			
			//Add the URL variables to the URL.
			if(params != null)
			{
				for(var param:String in params)
				{
					requestURL += "&" + param + "=" + params[param];
				}
			}
			
			//Add latency variable to the request.
			if(_gameServerData.useDevelopmentServer)
			{
				requestURL += "&latency=" + CGSServerConstants.serverLatency;
			}
			
			//Add a noCache variable to the URL.
			requestURL += "&noCache=" + CGSServer.getTimeStamp();
			
			return requestURL;
		}
	}
}