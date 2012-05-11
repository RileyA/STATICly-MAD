package cgs.server.logging
{
	public class CGSServerProps
	{
		private var _serverURL:String;
		
		private var _abTestingURL:String;
		
		private var _useDevServer:Boolean;
		
		private var _skeyHashType:int;
		
		//Properties which need to be set prior to starting logging. Should not change during a game session.
		
		//Skey must be set to enable logging to the server.
		private var _skey:String = null;
		
		private var _gameName:String = null;
		private var _gameID:int = -1;
		private var _versionID:int = -1;
		private var _categoryID:int = -1;
		
		//TODO - How should optional properties be handled.
		private var _levelID:int = -1;
		private var _sessionID:String = null;
		private var _eventID:int = -1;
		private var _typeID:int = -1;
		
		/**
		 * Create a server properties object with all propeties which are
		 * required to be set for the server logging to function properly.
		 * 
		 * @param skey key determined on the server which is used to validate requests to the server.
		 * 
		 * @param skeyHashType the type of hashing to use for creating the final skey of a server request.
		 * This should be set on the server.
		 * 
		 * @param gameName name of the game as defined on the server.
		 * 
		 * @param gameID id of the game as defined on the server.
		 * 
		 * @param versionID current version id of the game. Can be used to seperate logging messages on the server.
		 * 
		 * @param categoryID current category id for the game. This must be defined on the server for 
		 * logging to function properly.
		 * 
		 * @param serverURL base URL to be used for logging.
		 */
		public function CGSServerProps(skey:String, skeyHashType:int, gameName:String,
				gameID:int, versionID:int, categoryID:int, serverURL:String = null, useDevServer:Boolean = false, abTestURL:String = null)
		{
			_skey = skey;
			_skeyHashType = skeyHashType;
			
			_gameName = gameName;
			_gameID = gameID;
			_versionID = versionID;
			_categoryID = categoryID;
			
			_serverURL = serverURL;
			_abTestingURL = abTestURL;
			_useDevServer = useDevServer;
		}
		
		public function get skey():String
		{
			return _skey;
		}
		
		public function get isServerURLValid():Boolean
		{
			return _serverURL != null;
		}
		
		public function get serverURL():String
		{
			return _serverURL;
		}
		
		public function get isABTestingURLValid():Boolean
		{
			return _abTestingURL != null;
		}
		
		public function get abTestingURL():String
		{
			return _abTestingURL;
		}
		
		public function get useDevServer():Boolean
		{
			return _useDevServer;
		}
		
		public function get skeyHashVersion():int
		{
			return _skeyHashType;
		}
		
		public function get gameName():String
		{
			return _gameName;
		}
		
		public function get gameID():int
		{
			return _gameID;
		}
		
		public function get versionID():int
		{
			return _versionID;
		}
		
		public function get categoryID():int
		{
			return _categoryID;
		}
		
		//
		// Optional server properties.
		//
		
		public function set levelID(value:int):void
		{
			_levelID = value;
		}
		
		public function get levelID():int
		{
			return _levelID;
		}
		
		public function set sessionID(value:String):void
		{
			_sessionID = value;
		}
		
		public function get sessionID():String
		{
			return _sessionID;
		}
		
		public function set eventID(value:int):void
		{
			_eventID = value;
		}
		
		public function get eventID():int
		{
			return _eventID;
		}
		
		public function set typeID(value:int):void
		{
			_typeID = value;
		}
		
		public function get typeID():int
		{
			return _typeID;
		}
	}
}