package cgs.server.logging.requests
{
	public class CallbackRequest implements ICallbackRequest
	{
		protected var _callback:Function;
		
		protected var _returnDataType:String;
		
		public function CallbackRequest(callback:Function, returnType:String = "TEXT")
		{
			_callback = callback;
			_returnDataType = returnType;
		}
		
		public function get callback():Function
		{
			return _callback;
		}
		
		public function get returnDataType():String
		{
			return _returnDataType;
		}
	}
}