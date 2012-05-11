package cgs.server.logging.requests
{
	public class DQIDRequest extends CallbackRequest
	{
		public var localLevelID:int;
		
		public function DQIDRequest(id:int, callback:Function)
		{
			super(callback);
			localLevelID = id;
		}
	}
}