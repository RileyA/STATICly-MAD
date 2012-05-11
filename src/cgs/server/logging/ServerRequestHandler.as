package cgs.server.logging
{
	import cgs.server.logging.requests.IServerRequest;
	import cgs.server.logging.responses.IServerResponse;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;

	public class ServerRequestHandler implements IServerRequestHandler
	{
		private var _requestMap:Dictionary;
		
		public function ServerRequestHandler()
		{
			_requestMap = new Dictionary();
		}
		
		/**
		 * Make a request to the server.
		 */
		public function request(serverRequest:IServerRequest):void
		{
			var urlRequest:URLRequest;
			if(serverRequest.isPOST)
			{
				urlRequest = new URLRequest(serverRequest.baseURL);
				urlRequest.method = URLRequestMethod.POST;
				urlRequest.data = serverRequest.urlVariables;
			}
			else
			{
				urlRequest = new URLRequest(serverRequest.url);
				urlRequest.method = URLRequestMethod.GET;
			}
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = serverRequest.dataFormat;
			
			//Add event listeners for the request.
			urlLoader.addEventListener(Event.COMPLETE, handleRequestComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleRequestIOError);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleRequestHTTPStatus);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleRequestSecurityError);
			
			//Add the loader and request to the request map.
			_requestMap[urlLoader] = serverRequest;
			
			try
			{
				urlLoader.load(urlRequest);
			}
			catch(e:Error)
			{
				//Failed already. Need to handle local logging and callback.
				delete _requestMap[urlLoader];
				
				var callback:Function = serverRequest.callback;
				var extraData:* = serverRequest.extraData;
				if(callback != null)
				{
					if(extraData != null)
					{
						callback(null, true, extraData);
					}
					else
					{
						callback(null, true);
					}
				}
			}
		}
		
		//TODO - Implement response and error handling.
		private function handleRequestComplete(evt:Event):void
		{
			var urlLoader:URLLoader = evt.target as URLLoader;
			
			var request:IServerRequest = _requestMap[urlLoader];
			delete _requestMap[urlLoader];
			
			//Should not be null but just in case.
			if(request == null) return;
			
			//What type is the data format of the data loaded by the server?
			var dataFormat:String = request.dataFormat;
			
			var responseClass:Class = request.responseClass;
			var response:IServerResponse;
			var returnData:* = urlLoader.data;
			if(responseClass != null)
			{
				response = new responseClass();
				response.data = returnData;
				returnData = response;
			}
			
			var callback:Function = request.callback;
			if(callback != null)
			{
				var extraData:* = request.extraData;
				if(extraData == null)
				{
					callback(returnData, false);
				}
				else
				{
					callback(returnData, false, extraData);
				}
			}
		}
		
		private function handleRequestIOError(evt:IOErrorEvent):void
		{
			//Logger.print(this, "Server request IO Error: " + evt.text);
			handleRequestError(evt.target as URLLoader);
		}
		
		private function handleRequestHTTPStatus(evt:HTTPStatusEvent):void
		{
			//TODO - Implement handling for status codes. Some browser's can not
			//return status codes to flash. Can not rely on this function to work.
		}
		
		private function handleRequestSecurityError(evt:SecurityErrorEvent):void
		{
			//Logger.print(this, "Server request Security Error" + evt.text);
			handleRequestError(evt.target as URLLoader);
		}
		
		private function handleRequestError(urlLoader:URLLoader):void
		{
			var request:IServerRequest = _requestMap[urlLoader];
			delete _requestMap[urlLoader];
			
			//TODO - Should the request be cached?
			var callback:Function = request.callback;
			var extraData:* = request.extraData;
			if(callback != null)
			{
				if(extraData == null)
				{
					callback(null, true);
				}
				else
				{
					callback(null, true, extraData);
				}
			}
		}
	}
}