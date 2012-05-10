package cgs.server.logging.requests
{
	public class UUIDRequest extends CallbackRequest
	{
		public var cacheUUID:Boolean;
		
		public function UUIDRequest(callback:Function, cacheUUID:Boolean)
		{
			super(callback);
			this.cacheUUID = cacheUUID;
		}
	}
}