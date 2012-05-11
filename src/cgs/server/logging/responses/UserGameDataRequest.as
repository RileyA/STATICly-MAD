package cgs.server.logging.responses
{
	import cgs.server.logging.gamedata.UserGameData;

	/**
	 * Contains all of the users game data returned from the server.
	 */
	public class UserGameDataRequest implements IServerResponse
	{
		private var _gameData:UserGameData;
		
		public function UserGameDataRequest()
		{
		}
		
		public function get userGameData():UserGameData
		{
			return _gameData;
		}
		
		public function set data(value:*):void
		{
			_gameData = new UserGameData();
			_gameData.parseUserGameData(value);
		}
	}
}