package cgs.server.logging.requests
{
	public class GameDataRequest extends CallbackRequest
	{
		public var dataID:String;
		
		public function GameDataRequest(callback:Function, dataID:String)
		{
			super(callback);
			this.dataID = dataID;
		}
	}
}