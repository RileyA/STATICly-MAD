package cgs.server.logging.gamedata
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.utils.Dictionary;

	/**
	 * Contains all game data for this user.
	 */
	public class UserGameData
	{
		//Dictionary which contains all of the user data chunks.
		private var _gameData:Dictionary;
		
		public function UserGameData()
		{
			_gameData = new Dictionary();
		}
		
		/**
		 * Indicates if the data for the given key exists.
		 */
		public function containsData(key:String):Boolean
		{
			return _gameData.hasOwnProperty(key);
		}
		
		/**
		 * Get the save data with the associated key.
		 */
		public function getData(key:String):*
		{
			return _gameData[key];
		}
		
		/**
		 * Update the value of the data with the given key. The value should
		 * be a primitive value, array or an Object. No other values are supported.
		 */
		public function updateData(key:String, value:*):void
		{
			_gameData[key] = value;
		}
		
		/**
		 * Parse game data returned from the server.
		 */
		public function parseUserGameData(data:Array):void
		{
			var key:String;
			var rawData:*;
			var dataDecoder:JSONDecoder;
			for each(var dataChunk:Object in data)
			{
				key = dataChunk.u_data_id;
				rawData = dataChunk.data_detail;
				if(rawData is String)
				{
					dataDecoder = new JSONDecoder(rawData, true);
					_gameData[key] = dataDecoder.getValue();
				}
				else
				{
					_gameData[key] = rawData;
				}
				
			}
		}
	}
}