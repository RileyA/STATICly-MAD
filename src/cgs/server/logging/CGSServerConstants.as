package cgs.server.logging
{
	import com.adobe.crypto.MD5Stream;
	import com.adobe.serialization.json.JSONEncoder;
	
	import flash.utils.ByteArray;

	/**
	 * Contains all URL's, methods and constants for the game.
	 */
	public class CGSServerConstants
	{
		/**
		 * Production URL for the game. This needs to be set to proper URL for the game.
		 */
		public static const BASE_URL:String = "http://prd.ws.centerforgamescience.com/cgs/apps/games/ws/index.php/";
		
		/**
		 * Development URL for the game.
		 */
		public static const DEV_URL:String = "http://dev.ws.centerforgamescience.com/cgs/apps/games/ws/index.php/";
		
		//
		// Request methods which can be called on the server.
		//
		
		/**
		 * Sub-URL to get a UUID for a new user.
		 */
		public static const UUID_REQUEST:String = "muser/get/";
		
		/**
		 * Sub-URL to get a dqid.
		 */
		public static const DQID_REQUEST:String = "logging/getdynamicquestid/";
		
		/**
		 * Sub-URL to log the start of a quest.
		 */
		public static const LEGACY_QUEST_START:String = "loggingassessment/setquest/";
		
		public static const QUEST_START:String = "loggingqueststatus/set/";
		
		/**
		 * Sub-URL to log a quest action.
		 */
		public static const QUEST_ACTIONS:String = "logging/set/";
		
		/**
		 * Sub-URL to create a new quest on the server.
		 */
		public static const CREATE_QUEST:String = "questcreate/set/";
		
		/**
		 * Sub-URL to log user's demographic information.
		 */
		public static const USER_FEEDBACK:String = "loggingprofile/set/";
		
		/**
		 * Sub-URL to log a game event that is not associated with a quest.
		 */
		public static const ACTION_NO_QUEST:String = "loggingactionnoquest/set/";
		
		/**
		 * Sub-URL to log a page load for the user.
		 */
		public static const PAGELOAD:String = "loggingpageload/set/";
		
		/**
		 * Method to save a user's score to the server.
		 */
		public static const SAVE_SCORE:String = "loggingscore/set/";
		
		public static const SCORE_REQUEST:String = "loggingscore/getscoresbyids/";
		
		public static const SAVE_GAME_DATA:String = "loggingplayerdata/set/";
		
		public static const LOAD_USER_GAME_DATA:String = "loggingplayerdata/getbyuid/";
		
		public static const LOAD_GAME_DATA:String = "loggingplayerdata/getbyudataidnuid/";
		
		public static const TOS_DATA_ID:String = "tos_status";
		
		//
		// User log data request methods
		//
		
		public static const QUESTS_REQUEST:String = "logging/getquestsbyuserid/";
		
		public static const QUEST_ACTIONS_REQUEST:String = "logging/getactionsbydynamicquestid/";
		
		public static const PAGE_LOAD_BY_UID_REQUEST:String = "loggingpageload/getbyuid/";
		
		public static const DEMOGRAPHICS_GET_BY_UID:String = "loggingprofile/getbyuid/";
		
		//
		// Failure handling.
		//
		
		public static const LOG_FAILURE:String = "loggingfailure/set/";
		
		//
		// Logging request methods.
		//
		
		//LoggingController methods.
		
		public static const GET_ACTIONS_BY_DQID:String = "logging/getactionsbydynamicquestid/";
		
		/**
		 * Get the quest data for a cid and a timestamp range. Required data values are 'cid', 'tss' and 'tse'.
		 */
		public static const GET_QUESTS_BY_CID_TS:String = "logging/getquestsbycidnts/";
		
		/**
		 * Get quest actions data for a given timestamp range.
		 */
		public static const GET_ACTIONS_BY_CID_TS:String = "logging/getactionsbycidnts/";
		
		public static const GET_QUESTS_BY_UID:String = "logging/getquestsbyuserid/";
		
		
		//LoggingactionnoquestController methods.
		
		public static const GET_NO_QUEST_ACTIONS_BY_UID:String = "loggingactionnoquest/getbyuid/";
		
		
		//LoggingpageloadController methods.
		
		public static const GET_PAGELOADS_BY_UID:String = "loggingpageload/getbyuid/";
		
		
		//LoggingprofileController methods.
		
		public static const GET_PROFILE_BY_UID:String = "loggingprofile/getbyuid/";
		
		
		//LoggingqueststatusController
		
		public static const GET_QUEST_STATUS_BY_UID:String = "loggingqueststatus/getbyuid/";
		
		//
		// Buffer handler constants.
		//
		
		/**
		 * Time(ms) between log buffer flushes at the start of a quest.
		 */
		public static var bufferFlushIntervalStart:int = 2000;
		
		/**
		 * Time(ms) between buffer flushes after the ramp time has elapsed during a quest.
		 */
		public static var bufferFlushIntervalEnd:int = 5000;
		
		/**
		 * Time(ms) it takes to change from the start and end times for buffer flushing.
		 */
		public static var bufferFlushRampTime:int = 10000;
		
		/**
		 * Minimum number of logs that have to be in the buffer before a flush will occur.
		 */
		public static var bufferSizeMin:int = 1;
		
		/**
		 * Maximum number of actions allowed in action buffer before a flush is forced.
		 */
		public static var bufferFlushForceCount:int = 50;
		
		//
		// Server latency simulation.
		//
		
		/**
		 * Simulated server latency (in seconds) which can be used when logging to the development server.
		 */
		public static var serverLatency:int = 5;
		
		/**
		 * Get the game specific logging URL for the game with the given name.
		 */
		public function getGameLoggingURL(gameName:String):String
		{
			return "http://" + gameName + ".ws.centerforgamescience.com/cgs/apps/games/ws/index.php/";
		}
	}
}