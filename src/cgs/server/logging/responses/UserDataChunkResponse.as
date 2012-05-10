package cgs.server.logging.responses
{
	import cgs.server.logging.gamedata.UserDataChunk;

	public class UserDataChunkResponse implements IServerResponse
	{
		private var _dataChunk:UserDataChunk;
		
		public function UserDataChunkResponse()
		{
		}
		
		public function get dataChunk():UserDataChunk
		{
			return _dataChunk;
		}
		
		public function set data(value:*):void
		{
			var dataArray:Array = value;
			if(dataArray.length == 0) return;
			
			var dataObj:Object = dataArray[0];
			_dataChunk = new UserDataChunk(dataObj.u_data_id, dataObj.data_detail);
		}
	}
}