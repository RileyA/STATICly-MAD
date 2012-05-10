package cgs.server.logging.requests
{
	public class FailureRequest
	{
		//Method which failed to log on the server.
		protected var _method:String;
		
		//Count of failures.
		protected var _count:int;
		
		public function FailureRequest(method:String)
		{
			_method = method;
			_count = 0;
		}
		
		public function incrementCount(value:int):void
		{
			_count += value;
		}
		
		public function get count():int
		{
			return _count;
		}
		
		public function get method():String
		{
			return _method;
		}
	}
}