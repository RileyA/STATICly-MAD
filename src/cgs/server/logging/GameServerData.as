package cgs.server.logging
{
	import com.adobe.crypto.MD5Stream;
	
	import flash.utils.ByteArray;

	/**
	 * Contains server constants and data specific to a game and player session.
	 */
	public class GameServerData
	{
		public static const NO_SKEY_HASH:int = 0;
		public static const UUID_SKEY_HASH:int = 1;
		public static const DATA_SKEY_HASH:int = 2;
		
		public static const NO_DATA_ENCODING:int = 0;
		public static const BASE_64_ENCODING:int = 1;
		
		private static var _instance:GameServerData;
		
		//Indicates if messages should be sent in legacy mode.
		private var _legacyMode:Boolean;
		
		//URL used to log to the server.
		private var _serverURL:String;
		
		private var _abTestingURL:String;
		
		//Indicates if the development server is being used for logging.
		private var _useDevServer:Boolean;
		
		//Key used to validate logging messages on the server.
		private var _skey:String;
		
		//Indicates how the skey should be hashed for the game.
		private var _skeyHashVersion:int = UUID_SKEY_HASH;
		
		//Indicates the type of encoding to use for the data paramter.
		private var _encoding:int = NO_DATA_ENCODING;
		
		//Optional user name that can be set. Used for some requests to the server.
		private var _userName:String = "";
		
		//CGS user id for the current player session.
		private var _uuid:String = "";
		
		//Game id must be defined on the server.
		private var _gid:int;
		
		//Name of the game as defined on the server.
		private var _g_name:String;
		
		//Version id for the game.
		private var _vid:int;
		
		//Category id for the game. Must be defined on the server for logging to work.
		private var _cid:int;
		
		//Event id for the game. Parameter is optional for most messages. Will be
		//sent as 0 for required messages if not set.
		private var _eid:int = -1;
		
		//Type id for the game. This is required for action messages. Parameter is
		//optional for most messages. Will be sent as 0 for required messages if not set.
		private var _tid:int = -1;
		
		//Current level id. This is required for action messages. Parameter is
		//optional for most messages. Will be sent as 0 for required messages if not set.
		private var _lid:int = -1;
		
		//Parameter is optional for all messages.
		private var _sessionID:String;
		
		private var _swfDomain:String;
		
		public function GameServerData()
		{
		}
		
		public static function get instance():GameServerData
		{
			if(_instance == null)
			{
				_instance = new GameServerData();
			}
			
			return _instance;
		}
		
		//
		// Server url handling.
		//
		
		public static function set legacyMode(value:Boolean):void
		{
			instance.legacyMode = value;
		}
		
		public static function get legacyMode():Boolean
		{
			return instance.legacyMode;
		}
		
		public function get legacyMode():Boolean
		{
			return _legacyMode;
		}
		
		public function set legacyMode(value:Boolean):void
		{
			_legacyMode = value;
		}
		
		public static function set serverURL(value:String):void
		{
			instance.serverURL = value;
		}
		
		public function set serverURL(value:String):void
		{
			_serverURL = value;
		}
		
		public static function get serverURL():String
		{
			return instance.serverURL;
		}
		
		public function get serverURL():String
		{
			return _serverURL;
		}
		
		public static function set abTestingURL(value:String):void
		{
			instance.abTestingURL = value;
		}
		
		public function set abTestingURL(value:String):void
		{
			_abTestingURL = value;
		}
		
		public static function get abTestingURL():String
		{
			return instance.abTestingURL;
		}
		
		public function get abTestingURL():String
		{
			return _abTestingURL;
		}
		
		public static function set useDevelopmentServer(value:Boolean):void
		{
			instance.useDevelopmentServer = value;
		}
		
		public function set useDevelopmentServer(value:Boolean):void
		{
			_useDevServer = value;
		}
		
		public static function get useDevelopmentServer():Boolean
		{
			return instance.useDevelopmentServer;
		}
		
		public function get useDevelopmentServer():Boolean
		{
			return _useDevServer;
		}
		
		public static function set skeyHashVersion(value:int):void
		{
			instance.skeyHashVersion = value;
		}
		
		public function set skeyHashVersion(value:int):void
		{
			_skeyHashVersion = value;
		}
		
		public static function get skeyHashVersion():int
		{
			return instance.skeyHashVersion;
		}
		
		/**
		 * Indicates how the skey should be hashed and included in the URL.
		 */
		public function get skeyHashVersion():int
		{
			return _skeyHashVersion;
		}
		
		public static function get dataEncoding():int
		{
			return instance.dataEncoding;
		}
		
		public function get dataEncoding():int
		{
			return _encoding;
		}
		
		public static function set dataEncoding(value:int):void
		{
			instance.dataEncoding = value;
		}
		
		public function set dataEncoding(value:int):void
		{
			_encoding = value;
		}
		
		//
		// Convience methods to get data for server requests.
		//
		
		/**
		 * 
		 *
		public static function get uuidRequestData():Object
		{
			//TODO - Is vid needed for this request?
			return {gid:gid, g_name:g_name};//, vid:vid};//, skey:SKEY};
		}
		
		/**
		 * 
		 *
		public static function get dqidRequestData():Object 
		{
			//TODO - Is the vid needed for this request.
			return {gid:gid, g_name:g_name};//, vid:vid}; //, skey:getSkey()};
		}*/
		
		//
		// Skey handling.
		//
		
		public static function set skey(value:String):void
		{
			instance.skey = value;
		}
		
		public function set skey(value:String):void
		{
			_skey = value;
		}
		
		public static function get skey():String
		{
			return instance.skey;
		}
		
		public function get skey():String
		{
			return _skey;
		}
		
		/**
		 * Get the skey for the associated URL / uuid.
		 * 
		 * @param value the string value which should be used to create the hashed skey.
		 * @return a hashed version of the server skey.
		 */
		public static function createSkeyHash(value:String):String
		{
			return instance.createSkeyHash(value);
		}
		
		public function createSkeyHash(value:String):String
		{
			var hash:MD5Stream = new MD5Stream();
			var hashedBytes:ByteArray = new ByteArray();
			
			var salt:String = value + _skey;
			hashedBytes.writeUTFBytes(salt);
			hashedBytes.position = 0;
			hash.update(hashedBytes);
			
			return hash.complete();
		}
		
		/**
		 * Set the current user name for the game session.
		 * This is an optional parameter.
		 */
		public static function set userName(value:String):void
		{
			instance.userName = value;
		}
		
		public function set userName(value:String):void
		{
			_userName = value;
		}
		
		/**
		 * Get the user name for the current game session.
		 */
		public static function get userName():String
		{
			return instance.userName;
		}
		
		public function get userName():String
		{
			return _userName;
		}
		
		/**
		 * Set the current uuid for the game session.
		 * This must be set for the logging to function properly.
		 */
		public static function set uuid(value:String):void
		{
			instance.uuid = value;
		}
		
		public function set uuid(value:String):void
		{
			_uuid = value;
		}
		
		/**
		 * Get the UUID for the current game session.
		 */
		public static function get uuid():String
		{
			return instance.uuid;
		}
		
		public function get uuid():String
		{
			return _uuid;
		}
		
		/**
		 * Set the name for the game as defined by the server.
		 * This must be set for the logging to function properly.
		 */
		public static function set g_name(value:String):void
		{
			instance.g_name = value;
		}
		
		public function set g_name(value:String):void
		{
			_g_name = value;
		}
		
		/**
		 * Get the server defined name of the game.
		 */
		public static function get g_name():String
		{
			return instance.g_name;
		}
		
		public function get g_name():String
		{
			return _g_name;
		}
		
		/**
		 * Set the game id. This must be set for the logging to function properly.
		 */
		public static function set gid(value:int):void
		{
			instance.gid = value;
		}
		
		public function set gid(value:int):void
		{
			_gid = value;
		}
		
		/**
		 * Get the game id.
		 */
		public static function get gid():int
		{
			return instance.gid;
		}
		
		public function get gid():int
		{
			return _gid;
		}
		
		/**
		 * Get the version server vid for the game.
		 */
		public static function get svid():int
		{
			return instance._skeyHashVersion;
		}
		
		public function get svid():int
		{
			return _skeyHashVersion;
		}
		
		/**
		 * Set the version id for the game.
		 */
		public static function set vid(value:int):void
		{
			instance.vid = value;
		}
		
		public function set vid(value:int):void
		{
			_vid = value;
		}
		
		/**
		 * Get the version id for the game.
		 */
		public static function get vid():int
		{
			return instance.vid;
		}
		
		public function get vid():int
		{
			return _vid;
		}
		
		/**
		 * Set the category id for the game.
		 */
		public static function set cid(value:int):void
		{
			instance.cid = value;
		}
		
		public function set cid(value:int):void
		{
			_cid = value;
		}
		
		/**
		 * Get the category id for the game.
		 */
		public static function get cid():int
		{
			return instance.cid;
		}
		
		public function get cid():int
		{
			return _cid;
		}
		
		/**
		 * Indicates if the tid has been explicitly set.
		 */
		public static function get isEventIDValid():Boolean
		{
			return instance.isEventIDValid;
		}
		
		public function get isEventIDValid():Boolean
		{
			return _eid >= 0;
		}
		
		/**
		 * Set the event id for the game.
		 */
		public static function set eid(value:int):void
		{
			instance.eid = value;
		}
		
		public function set eid(value:int):void
		{
			_eid = value;
		}
		
		/**
		 * Get the event id for the game.
		 */
		public static function get eid():int
		{
			return instance.eid;
		}
		
		public function get eid():int
		{
			return _eid;
		}
		
		/**
		 * Indicates if the tid has been explicitly set.
		 */
		public static function get isTypeIDValid():Boolean
		{
			return instance.isTypeIDValid;
		}
		
		public function get isTypeIDValid():Boolean
		{
			return _tid >= 0;
		}
		
		/**
		 * Set the type id for the game.
		 */
		public static function set tid(value:int):void
		{
			instance.tid = value;
		}
		
		public function set tid(value:int):void
		{
			_tid = value;
		}
		
		/**
		 * Get the type id for the game.
		 */
		public static function get tid():int
		{
			return instance.tid;
		}
		
		public function get tid():int
		{
			return _tid;
		}
		
		/**
		 * Indicates if the lid has been explicitly set.
		 */
		public static function get isLevelIDValid():Boolean
		{
			return instance.isLevelIDValid;
		}
		
		public function get isLevelIDValid():Boolean
		{
			return _lid >= 0;
		}
		
		/**
		 * Set the current level id for the game.
		 */
		public static function set lid(value:int):void
		{
			instance.lid = value;
		}
		
		public function set lid(value:int):void
		{
			_lid = value;
		}
		
		/**
		 * Get the current level id for the game.
		 */
		public static function get lid():int
		{
			return instance.lid;
		}
		
		public function get lid():int
		{
			return _lid;
		}
		
		/**
		 * Indicates if the session id has been explicitly set.
		 */
		public static function get isSessionIDValid():Boolean
		{
			return instance.isSessionIDValid;
		}
		
		public function get isSessionIDValid():Boolean
		{
			return _sessionID != null;
		}
		
		/**
		 * Set the session id for the game.
		 */
		public static function set sid(value:String):void
		{
			instance.sid = value;
		}
		
		public function set sid(value:String):void
		{
			_sessionID = value;
		}
		
		/**
		 * Get the current level id for the game.
		 */
		public static function get sid():String
		{
			return instance.sid;
		}
		
		public function get sid():String
		{
			return _sessionID;
		}
		
		//
		// SWF domain handling.
		//
		
		public static function get isSWFDomainValid():Boolean
		{
			return instance.isSWFDomainValid;
		}
		
		public function get isSWFDomainValid():Boolean
		{
			return _swfDomain != null;
		}
		
		public static function get swfDomain():String
		{
			return instance.swfDomain;
		}
		
		public function get swfDomain():String
		{
			return _swfDomain;
		}
		
		public static function set swfDomain(value:String):void
		{
			instance.swfDomain = value;
		}
		
		public function set swfDomain(value:String):void
		{
			_swfDomain = value;
		}
	}
}