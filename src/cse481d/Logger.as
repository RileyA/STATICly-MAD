package cse481d
{
	import cgs.server.logging.CGSServer;
	import cgs.server.logging.CGSServerConstants;
	import cgs.server.logging.CGSServerProps;
	import cgs.server.logging.actions.ClientAction;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Logger
	{
		private var server:CGSServer;
		private var lastQid:int = -1;
		private var levelStartTime:Number;

		private static function loadUrl(req:URLRequest, callback:Function):void {
			var loader:URLLoader = new URLLoader();

			loader.addEventListener(Event.COMPLETE, onLoad);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);

			try {
				loader.load(req);
			} catch (e:Error) {
				callback(null);
			}
			
			function onLoad(e:Event):void {
				loader.removeEventListener(Event.COMPLETE, onLoad);
				callback((e.target as URLLoader).data);
			}
			
			function onError(e:IOErrorEvent):void {
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				//Let the callback know we've failed with a null argument
				callback(null);
			}
		}
		
		/**
		 * Creates the logger given game data. gid, name, and skey should
		 * have been provided to you and are unique to your game.
		 * The data object can be an arbitrary AS object, which will be
		 * converted to JSON and stored with the a pageload log.
		 * The system will also automatically log system information such
		 * as their OS, language settings, etc.
		 * Returns the logger, which is available for immediate use.
		 */
		public static function initialize(gid:int, name:String, skey:String, data:Object):Logger
		{
			if (gid <= 0 || name == null || skey == null) throw new ArgumentError("invalid game info");
			
			var logger:Logger = new Logger();

			var DOLOG_URL:String = "http://games.cs.washington.edu/cgs/py/cse481d/dolog.py?gid=" + gid.toString() + "&code=304236658355552";
			
			logger.server = new CGSServer();
			var props:CGSServerProps = new CGSServerProps(skey, 0, name, gid, 1, 1, CGSServerConstants.DEV_URL, false, null);
			logger.server.init(props,false);
			
			logger.server.requestUUID(function(uuid:String, failed:Boolean):void {
				trace(uuid);
				logger.server.logPageLoad(data);
			}, true);
			
			var request:URLRequest = new URLRequest(DOLOG_URL);
			request.method = "GET";
			loadUrl(request, function(result:String):void {
				if (result == null || result.charAt(0) != "1") {
					logger.server.disableLogging();
				}
			});

			return logger;
		}

		/**
		 * Logs the start of a level with the given level qid.
		 * You should guarantee each level in you game has a distict qid.
		 * The data object can be an arbitrary AS object, which will be
		 * converted to JSON and stored with the log.
		 * A dqid will be automatically generated for this trace.
		 * Call logLevelEnd once the trace is over (though this isn't necessary
		 * for logging purposes so everyting is still logged if the player,
		 * say, closes the browser during the level).
		 */
		public function logLevelStart(qid:int, data:Object):void
		{
			if (qid <= 0) throw new ArgumentError("qid must be positive");
			lastQid = qid;
			server.logQuestStart(qid, data);
			levelStartTime = new Date().time;
		}

		/**
		 * Logs an action of the given action type aid.
		 * The action will be associated with the current trace,
		 * so make sure to call logLevelStart before logging actions.
		 * The data object can be an arbitrary AS object, which will be
		 * converted to JSON and stored with the log.
		 */
		public function logAction(aid:int, data:Object):void
		{
			if (aid <= 0) throw new ArgumentError("aid must be positive");
			var action:ClientAction = new ClientAction(aid, new Date().time - levelStartTime);
			action.setDetail(data);
			server.logQuestAction(action);
		}

		/**
		 * Logs the end of a level, which ends the trace.
		 * You must have first called logLevelStart.
		 * The data object can be an arbitrary AS object, which will be
		 * converted to JSON and stored with the log.
		 */
		public function logLevelEnd(data:Object):void
		{
			if (lastQid == -1) throw new ArgumentError("no active level");
			lastQid = -1;
			server.logQuestEnd(lastQid, data);
		}
	}
}