package cgs.server.logging.messages
{
	import cgs.server.logging.GameServerData;

	/**
	 * ...
	 * @author Dmitri/Yun-En/Aaron
	 * 
	 * Message class contains a list of header variables (logging schema specific) and an optional action buffer.
	 * You'll need to set gid, cid, and qid yourself.
	 *   Gid will be the same for each game, always; look in the database to find yours.
	 *   Cid will be set by you to whatever you want, although it will probably change for new events or releases.
	 *   Qid depends on what quest in the game you're currently playing.
	 * 
	 * You may also want to use vid, although cid most likely suffices.
	 * 
	 * In general you'll call CGSClient's setUser to set the uid, and setDqid to set the dqid.
	 * You also probably don't care about the optional fields.
	 * 
	 * What is cid, you ask?  It's typically used when you want to segregate data from some particular real-life event.
	 * For instance, you ask 50 people to playtest your game.  It's going to be a pain to look through the database
	 * for those exact 50 people.  However, if you compile a version of the game with a new cid, you can simply
	 * do one database call to get every action with cid 5.  Then you can bump cid again for new builds.
	 * 
	 * What's the difference between vid and cid, then?
	 * Vid is conceptually the version of your game; new versions may have new levels or mechanics.
	 * You might use the same vid for several different real life events, each with their own cid.
	 * It's also possible that you'd have different versions of the game for the same cid -
	 * imagine playtesting three different versions of the game at once.
	 * That being said, as long as you write down what each cid is, you can probably do everything just
	 * by bumping cids for each version, in which case you can ignore vid and just let it default to 0.  
	 * 
	 * NOTE:
	 * If you are using JSON encoding, do not create getters protected/private properties that you do not want to encode.
	 * 
	 */
	public dynamic class Message
	{
		protected var _messageObject:Object;
		
		protected var _gameServerData:GameServerData;
		
		/**
		 * @param serverData this value must be set if you are not using the CGSServer singleton instance.
		 */
		public function Message(serverData:GameServerData = null)
		{
			_messageObject = {};
			
			_gameServerData = serverData == null ? GameServerData.instance : serverData;
		}
		
		public function set serverData(data:GameServerData):void
		{
			_gameServerData = data;
		}
		
		/**
		 * Add a property to the message object to be sent to the server.
		 */
		public function addProperty(key:String, value:*):void
		{
			_messageObject[key] = value;
		}
		
		/**
		 * Get the object which will be encoded to JSON and sent the server.
		 */
		public function get messageObject():Object
		{
			return _messageObject;
		}
		
		/**
		 * Inject the SKEY into the message.
		 */
		public function injectSKEY():void
		{
			//Add data that is required for all messages to the server.
			var skeyHashType:int = _gameServerData.skeyHashVersion;
			if(skeyHashType == GameServerData.UUID_SKEY_HASH)
			{
				//Skey should be cached once the user id is set.
				_messageObject.skey = _gameServerData.createSkeyHash(GameServerData.uuid);
			}
			else if(skeyHashType == GameServerData.NO_SKEY_HASH)
			{
				_messageObject.skey = _gameServerData.skey;
			}
		}
		
		/**
		 * Adds the game name and game id parameters to the message. These
		 * parameters are required for all requests/messages sent to the server.
		 */
		public function injectGameParams():void
		{
			_messageObject.g_name = _gameServerData.g_name;
			_messageObject.gid = _gameServerData.gid;
			_messageObject.vid = _gameServerData.vid;
			
			if(!_gameServerData.legacyMode)
			{
				_messageObject.svid = _gameServerData.svid;
			}
		}
		
		/**
		 * Adds required parameters to the message. Injects the skey as well if required.
		 */
		public function injectParams():void
		{
			injectGameParams();
			
			_messageObject.uid = _gameServerData.uuid;
			_messageObject.cid = _gameServerData.cid;
			
			injectSKEY();
		}
		
		public function injectUserName():void
		{
			_messageObject.uname = _gameServerData.userName;
		}
		
		/**
		 * Injects an event id into the message. If event id has not been set, event id is assumed to be 0.
		 */
		public function injectEventID(required:Boolean):void
		{
			if(required || _gameServerData.isEventIDValid)
			{
				_messageObject.eid = _gameServerData.isEventIDValid ? _gameServerData.eid : 0;
			}
		}
		
		/**
		 * 
		 */
		public function injectTypeID(required:Boolean):void
		{
			if(required || _gameServerData.isTypeIDValid)
			{
				_messageObject.tid = _gameServerData.isTypeIDValid ? _gameServerData.tid : 0;
			}
		}
		
		public function injectLevelID(required:Boolean):void
		{
			if(required || _gameServerData.isLevelIDValid)
			{
				_messageObject.lid = _gameServerData.isLevelIDValid ? _gameServerData.lid : 0;
			}
		}
		
		public function injectSessionID(required:Boolean):void
		{
			if(required || _gameServerData.isSessionIDValid)
			{
				_messageObject.sid = _gameServerData.isSessionIDValid ? _gameServerData.sid : "0";
			}
		}
	}
}