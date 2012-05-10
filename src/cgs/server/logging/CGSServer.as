package cgs.server.logging
{
	import cgs.Cache.Cache;
	import cgs.server.abtesting.ABTesterConstants;
	import cgs.server.abtesting.IABTestingServer;
	import cgs.server.abtesting.messages.ConditionVariableMessage;
	import cgs.server.abtesting.messages.TestStatusMessage;
	import cgs.server.logging.actions.ClientAction;
	import cgs.server.logging.actions.DefaultActionBufferHandler;
	import cgs.server.logging.actions.IActionBufferHandler;
	import cgs.server.logging.actions.IActionBufferListener;
	import cgs.server.logging.gamedata.UserDataChunk;
	import cgs.server.logging.gamedata.UserGameData;
	import cgs.server.logging.messages.ActionNoQuestMessage;
	import cgs.server.logging.messages.BufferedMessage;
	import cgs.server.logging.messages.CreateQuestRequest;
	import cgs.server.logging.messages.IQuestMessage;
	import cgs.server.logging.messages.Message;
	import cgs.server.logging.messages.PageloadMessage;
	import cgs.server.logging.messages.QuestMessage;
	import cgs.server.logging.messages.ScoreMessage;
	import cgs.server.logging.messages.UserFeedbackMessage;
	import cgs.server.logging.requests.CallbackRequest;
	import cgs.server.logging.requests.DQIDRequest;
	import cgs.server.logging.requests.FailureRequest;
	import cgs.server.logging.requests.GameDataRequest;
	import cgs.server.logging.requests.IServerRequest;
	import cgs.server.logging.requests.QuestRequest;
	import cgs.server.logging.requests.ServerRequest;
	import cgs.server.logging.requests.UUIDRequest;
	import cgs.server.logging.responses.UserDataChunkResponse;
	import cgs.server.logging.responses.UserGameDataRequest;
	
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSONEncoder;
	
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	/**
	 * Implementation of API to log and request data from the CGS logging server. Call init()
	 * to initialize the server with it starting properties @see CGSServerProps. Once this is called
	 * the user id should be requested/set before any requests are made to the server.
	 */
	public class CGSServer implements IActionBufferListener, ICGSLoggingServer, IABTestingServer
	{
		public static const LOG_ALL_DATA:int = 1;
		public static const LOG_PRIORITY_ACTIONS:int = 2;
		public static const LOG_NO_ACTIONS:int = 4;
		
		//Should the game continue working at this point?
		public static const LOG_NO_DATA:int = 6;
		public static const LOG_AND_SAVE_NO_DATA:int = 7;
		
		//Singleton instance of server.
		private static var _instance:CGSServer;
		
		//This is called when the server responds with a logging priority change.
		//Function should have following signature: callback(priority:int):void.
		private var _logPriorityChangeCallback:Function;
		
		//Requests which have been sent to the server and are awaiting a response.
		//private var _requestMap:Dictionary;
		
		//Map of log failues.
		private var _logFailures:Dictionary;
		private var _totalLogFailures:int;
		
		//Mapping of messages which are waiting for a dynamic quest id to
		//be returned from the server.
		private var _waitingMessages:Dictionary;
		
		private var _dynamicQuestIDMap:Dictionary;
		
		//Handles action messages for multiple quests. Key = localDQID, value = BufferedMessage
		private var _bufferedMessages:Dictionary;
		private var _openQuests:int = 0;
		
		//Current buffer message used to aggregate actions to batch send to the server.
		private var _lastBufferedMessage:BufferedMessage;
		
		//Local quest id generator. Used to handle the case where the server
		//take a while to respond and two quests are played consecutively with
		//the same qid.
		private var _localQuestID:int = 0;
		
		//Optional parameter which is used to override game id for quest messages.
		private var _questGameID:int = -1;
		
		//Class used to create the action buffer handler. This 
		//class must implement IActionBufferHandler.
		private var _actionBufferHandlerClass:Class;
		
		//Handles flushing of the action buffer.
		private var _actionBufferHandler:IActionBufferHandler;
		
		private var _requestHandlerClass:Class = ServerRequestHandler;
		
		//Handles requests to the server. Implemented as it's own class to handle
		//local unit testing.
		private var _requestHandler:IServerRequestHandler;
		
		//Timer used to send failed log messages to the server.
		private var _logFailuresEnabled:Boolean = false;
		private var _timer:Timer;
		private var _logFailureTime:int = 30000;
		
		//Local logging disable flag.
		private var _loggingDisabled:Boolean = false;
		
		//Terms of service disable flag.
		private var _requireTermsService:Boolean = false;
		private var _userAcceptedTOS:Boolean = false;
		
		//Current server logging priority.
		private var _serverLoggingPriority:int = LOG_ALL_DATA;
		private var _priorityMap:Dictionary;
		
		//Indicates the version of the response recieved from the server.
		private var _currentResponseVersion:int;
		
		private var _swfDomain:String;
		private var _gameServerData:GameServerData;
		
		public function CGSServer()
		{
			_waitingMessages = new Dictionary();
			_dynamicQuestIDMap = new Dictionary();
			_bufferedMessages = new Dictionary();
			_logFailures = new Dictionary();
			
			_actionBufferHandlerClass = DefaultActionBufferHandler;
			
			_requestHandler = new _requestHandlerClass();
			setupLogPriorites();
		}
		
		//Creates a mapping of logging functions and what priority they are allowed to log at.
		private function setupLogPriorites():void
		{
			if(_priorityMap == null)
			{
				_priorityMap = new Dictionary();
			}
			
			//Add all of logging and saving methods.
			_priorityMap[CGSServerConstants.ACTION_NO_QUEST] = LOG_PRIORITY_ACTIONS;
			_priorityMap[CGSServerConstants.DQID_REQUEST] = LOG_NO_ACTIONS;
			_priorityMap[CGSServerConstants.LEGACY_QUEST_START] = LOG_NO_ACTIONS;
			_priorityMap[CGSServerConstants.LOAD_GAME_DATA] = LOG_NO_DATA;
			_priorityMap[CGSServerConstants.LOAD_USER_GAME_DATA] = LOG_NO_DATA;
			_priorityMap[CGSServerConstants.LOG_FAILURE] = LOG_AND_SAVE_NO_DATA;
			_priorityMap[CGSServerConstants.PAGELOAD] = LOG_NO_ACTIONS;
			_priorityMap[CGSServerConstants.QUEST_ACTIONS] = LOG_PRIORITY_ACTIONS;
			_priorityMap[CGSServerConstants.SAVE_GAME_DATA] = LOG_NO_DATA;
			_priorityMap[CGSServerConstants.QUEST_START] = LOG_NO_ACTIONS;
			_priorityMap[CGSServerConstants.SAVE_SCORE] = LOG_NO_DATA;
			_priorityMap[CGSServerConstants.SCORE_REQUEST] = LOG_NO_DATA;
			_priorityMap[CGSServerConstants.USER_FEEDBACK] = LOG_NO_DATA;
			_priorityMap[CGSServerConstants.UUID_REQUEST] = LOG_AND_SAVE_NO_DATA;
		}
		
		//
		// Reset and clean up singleton instance.
		//
		
		public static function resetSingleton():void
		{
			_instance = null;
		}
		
		public function resetSingleton():void
		{
			_instance = null;
		}
		
		//
		// Properties handling.
		//
		
		public static function failureLoggingEnabled(value:Boolean):void
		{
			instance._logFailuresEnabled = value;
		}
		
		/**
		 * Set function which will be called when the server changes the priority of log messages.
		 */
		public static function set logPriorityChangeCallback(value:Function):void
		{
			instance.logPriorityChangeCallback = value;
		}
		
		public function set logPriorityChangeCallback(value:Function):void
		{
			_logPriorityChangeCallback = value;
		}
		
		/**
		 * Disables all logging to the logging server and the ab testing engine.
		 */
		public static function disableLogging():void
		{
			instance.disableLogging();
		}
		
		public function disableLogging():void
		{
			_loggingDisabled = true;
		}
		
		public static function enableLogging():void
		{
			instance.enableLogging();
		}
		
		public function enableLogging():void
		{
			_loggingDisabled = false;
		}
		
		/**
		 * Only set this if logging should be disabled if the terms of service is declined.
		 * This should be false in nearly all cases.
		 */
		public static function set requireTermsOfService(value:Boolean):void
		{
			instance.requireTermsOfService = value;
		}
		
		public function set requireTermsOfService(value:Boolean):void
		{
			_requireTermsService = value;
		}
		
		public static function set termsServiceAccepted(value:Boolean):void
		{
			instance.termsServiceAccepted = value;
		}
		
		public static function get termsServiceAccepted():Boolean
		{
			return instance._userAcceptedTOS;
		}
		
		public function set termsServiceAccepted(value:Boolean):void
		{
			_userAcceptedTOS = value;
		}
		
		/**
		 * Indicates if logging to the server or ab testing is enabled.
		 */
		private function loggingDisabled(method:String = null):Boolean
		{
			var priorityLogDisable:Boolean = false;
			/*if(method != null && _priorityMap.hasOwnProperty(method))
			{
				var priority:int = _priorityMap[method];
				priorityLogDisable = _serverLoggingPriority > priority;
			}*/

			//TODO - This should still save the user data to the server.
			return _loggingDisabled || (_requireTermsService && !_userAcceptedTOS) || priorityLogDisable;
		}
		
		public static function set actionBufferHandlerClass(bufferClass:Class):void
		{
			instance.actionBufferHandlerClass = bufferClass;
		}
		
		public function set actionBufferHandlerClass(bufferClass:Class):void
		{
			_actionBufferHandlerClass = bufferClass;
		}
		
		public static function set serverRequestHandlerClass(handlerClass:Class):void
		{
			instance.serverRequestHandlerClass = handlerClass;
		}
		
		public function set serverRequestHandlerClass(handlerClass:Class):void
		{
			_requestHandlerClass = handlerClass;
		}
		
		public static function set serverRequestHandler(handler:IServerRequestHandler):void
		{
			instance.serverRequestHandler = handler;
		}
		
		public function set serverRequestHandler(handler:IServerRequestHandler):void
		{
			_requestHandler = handler;
		}
		
		/**
		 * Initialize the CGS server class with the given properties. This
		 * should be called prior to making any requests to the server.
		 * After this function is called, one of the functions that sets / requests
		 * the CGS uuid from the server must be called prior to logging any information.
		 * 
		 * @param props initial properties to be set on the server.
		 * @param useDataSingleton indicates if the singleton instance of the GameServerData should be used. If
		 * you need more than one instance of CGSServer this should be false.
		 */
		public static function init(props:CGSServerProps, useDataSingleton:Boolean = true):void
		{
			instance.init(props, useDataSingleton);
		}
		
		public function init(props:CGSServerProps, useDataSingleton:Boolean = true):void
		{
			_gameServerData = useDataSingleton ? GameServerData.instance : new GameServerData();
			
			_gameServerData.skey = props.skey;
			_gameServerData.g_name = props.gameName;
			_gameServerData.gid = props.gameID;
			_gameServerData.cid = props.categoryID;
			_gameServerData.vid = props.versionID;
			
			// throw exceptions for invalid properties
			if (!props.isServerURLValid) {
				throw new ArgumentError();
			}
			
			_gameServerData.serverURL = props.isServerURLValid ? props.serverURL : CGSServerConstants.BASE_URL;
			_gameServerData.abTestingURL = props.isABTestingURLValid ? props.abTestingURL : ABTesterConstants.AB_TEST_URL_DEV;
			_gameServerData.useDevelopmentServer = props.useDevServer;
			_gameServerData.skeyHashVersion = props.skeyHashVersion;
			
			if(_swfDomain != null)
			{
				_gameServerData.swfDomain = _swfDomain;
			}
		}
		
		public static function get serverData():GameServerData
		{
			return instance.serverData;
		}
		
		public function get serverData():GameServerData
		{
			return _gameServerData;
		}
		
		public static function set skey(value:String):void
		{
			instance.skey = value;
		}
		
		public function set skey(value:String):void
		{
			_gameServerData.skey = value;
		}
		
		public static function set skeyHashVersion(value:int):void
		{
			instance.skeyHashVersion = value;
		}
		
		public function set skeyHashVersion(value:int):void
		{
			_gameServerData.skeyHashVersion = value;
		}
		
		public static function set gameName(value:String):void
		{
			instance.gameName = value;
		}
		
		public function set gameName(value:String):void
		{
			_gameServerData.g_name = value;
		}
		
		public static function set gameID(value:int):void
		{
			instance.gameID = value;
		}
		
		public function set gameID(value:int):void
		{
			_gameServerData.gid = value;
		}
		
		public static function set questGameID(value:int):void
		{
			instance.questGameID = value;
		}
		
		public function set questGameID(value:int):void
		{
			_questGameID = value;
		}
		
		public static function set versionID(value:int):void
		{
			instance.versionID = value;
		}
		
		public function set versionID(value:int):void
		{
			_gameServerData.vid = value;
		}
		
		public static function set catergoryID(value:int):void
		{
			instance.categoryID = value;
		}
		
		public function set categoryID(value:int):void
		{
			_gameServerData.cid = value;
		}
		
		public static function set serverURL(value:String):void
		{
			instance.serverURL = value;
		}
		
		public function set serverURL(value:String):void
		{
			_gameServerData.serverURL = value;
		}
		
		public static function set useDevelopmentServer(value:Boolean):void
		{
			instance.useDevelopmentServer = value;
		}
		
		public function set useDevelopmentServer(value:Boolean):void
		{
			_gameServerData.useDevelopmentServer = value;
		}
		
		public static function set abTestingURL(value:String):void
		{
			instance.abTestingURL = value;
		}
		
		public function set abTestingURL(value:String):void
		{
			_gameServerData.abTestingURL = value;
		}
		
		public static function set legacyMode(value:Boolean):void
		{
			instance.legacyMode = value;
		}
		
		public function set legacyMode(value:Boolean):void
		{
			_gameServerData.legacyMode = value;
		}
		
		/**
		 * Get the singleton instance of the CGSServer.
		 */
		public static function get instance():CGSServer
		{
			if(_instance == null)
			{
				_instance = new CGSServer();
			}
			
			return _instance;
		}
		
		//
		// User domain handling.
		//
		
		/**
		 * Store a reference to the domain that the SWF was loaded into.
		 */
		public static function setUserDomain(stage:Stage):void
		{
			if(stage == null) return;
			
			var domain:String = stage.root.loaderInfo.url.split("/")[2];
			domain = domain == null ? "" : domain;
			if(domain.length == 0)
			{
				domain = "local";
			}
			
			instance._swfDomain = domain;
			if(instance._gameServerData != null)
			{
				instance._gameServerData.swfDomain = domain;
			}
		}
		
		/**
		 * Get a server message with properties for this server already set.
		 */
		public function getServerMessage():Message
		{
			return new Message(_gameServerData);
		}
		
		//
		// Generic server request handling.
		//
		
		/**
		 * Generic request should only be used for non-logging and non-abtesting requests.
		 */
		public static function genRequest(url:String, method:String, callback:Function = null, data:Object = null,
	  			params:Object = null, extraData:* = null, responseClass:Class = null, dataFormat:String = URLLoaderDataFormat.TEXT):void
		{
			instance.genRequest(url, method, callback, data, params, extraData, responseClass, dataFormat);
		}
		
		/**
		 * Generic request should only be used for non-logging and non-abtesting requests.
		 */
		public function genRequest(url:String, method:String, callback:Function = null, data:Object = null,
				params:Object = null, extraData:* = null, responseClass:Class = null, dataFormat:String = URLLoaderDataFormat.TEXT):void
		{
			var request:ServerRequest = new ServerRequest(method, callback, data, params, extraData, responseClass, dataFormat, url, _gameServerData);
			request.urlType = ServerRequest.GENERAL_URL;
			_requestHandler.request(request);
		}
		
		public static function request(method:String, callback:Function = null, data:Object = null,
				params:Object = null, extraData:* = null, responseClass:Class = null, dataFormat:String = URLLoaderDataFormat.TEXT):void
		{
			instance.request(method, callback, data, params, extraData, responseClass, dataFormat);
		}
		
		/**
		 * Make a generic logging request to the CGS server. This function only needs to be used if there is not an
		 * appropriate function for the desired request to the server.
		 * 
		 * @param method the method to call on the server, @see CGSServerConstants for list of possible methods.
		 * 
		 * @param callback function which will be called when the server responds.
		 * Callback needs to have the method signature of (response:*, failed:Boolean, extraData:* = null):void.
		 * The extra data parameter only needs to be included in the callback if extra data is specified in the request.
		 * 
		 * @param responseClass class which should be created when the server responds. This class must
		 * extend IServerResponse. If the reponse class is not specified, the raw data recieved from the
		 * server will be returned to the callback.
		 * 
		 * @param data Object which will be converted to a JSON formatted string. Object must contain
		 * all required paramters for the server request method. The object should not contain
		 * any dynamic properties which need to be sent to the server, unless it is of type object.
		 * This is due to the fact that the JSON encoder used does not handle dynamic properties.
		 * The skey needs to be included in the object.
		 * 
		 * @param params URL variables which will be added to the request to the server.
		 * 
		 * @param dataFormat the type of the data to be returned from the server. Valid values
		 * are contained within URLLoaderDataFormat class.
		 * 
		 * @param extraData arbitrary object which can be cached with the server request.
		 * 
		 */
		public function request(method:String, callback:Function = null, data:Object = null,
				params:Object = null, extraData:* = null, responseClass:Class = null, dataFormat:String = URLLoaderDataFormat.TEXT):void
		{
			//TODO - Add handling for local logging and UUID not being set?
			if(loggingDisabled(method))
			{
				//Callback with a failed message and null return value.
				if(callback != null)
				{
					if(extraData == null)
					{
						callback(null, true);
					}
					else
					{
						callback(null, true, extraData);
					}
				}
				return;
			}
			
			//Create the server request object.
			var request:ServerRequest = new ServerRequest(method, callback, data, params, extraData, responseClass, dataFormat, null, _gameServerData);
			_requestHandler.request(request);
		}
		
		public static function abRequest(method:String, callback:Function = null, data:Object = null,
				params:Object = null, extraData:* = null, responseClass:Class = null, dataFormat:String = "TEXT"):void
		{
			instance.abRequest(method, callback, data, params, extraData, responseClass, dataFormat);
		}
		
		public function abRequest(method:String, callback:Function = null, data:Object = null,
				params:Object = null, extraData:* = null, responseClass:Class = null, dataFormat:String = "TEXT"):void
		{
			if(loggingDisabled(method))
			{
				//Callback with a failed message and null return value.
				if(callback != null)
				{
					if(extraData == null)
					{
						callback(null, true);
					}
					else
					{
						callback(null, true, extraData);
					}
				}
				return;
			}
			
			var request:ServerRequest = new ServerRequest(method, callback, data, params, extraData, responseClass, dataFormat, null, _gameServerData);
			request.urlType = ServerRequest.AB_TESTING_URL;
			_requestHandler.request(request);
		}
		
		//
		// AB testing handling.
		//
		
		public static function requestUserTestConditions(callback:Function = null):void
		{
			instance.requestUserTestConditions(callback);
		}
		
		public function requestUserTestConditions(callback:Function = null):void
		{
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			var message:Message = new Message(_gameServerData);
			message.injectParams();
			
			abRequest(ABTesterConstants.GET_USER_CONDITIONS, handleABTestConditions, message.messageObject, null, callbackRequest);
			//var abRequest:ServerRequest = new ServerRequest(, null, URL);
			//abRequest.urlType = ServerRequest.AB_TESTING_URL;
			//_requestHandler.request(abRequest);
		}
		
		private function handleABTestConditions(response:String, failed:Boolean, callbackRequest:CallbackRequest):void
		{
			var callback:Function = callbackRequest.callback;
			
			var responseObj:Object = null;
			if(!failed)
			{
				responseObj = parseResponseData(response);
				//failed = didRequestFail(responseObj);
			}
			
			if(failed)
			{
				logFailure(ABTesterConstants.GET_USER_CONDITIONS);
			}
			if(callback != null)
			{
				callback(responseObj, failed);
			}
		}
		
		/**
		 * Set the user as having no conditions. If the user already has test conditions,
		 * this will have no effect.
		 */
		public static function noUserConditions():void
		{
			instance.noUserConditions();
		}
		
		public function noUserConditions():void
		{
			var message:Message = new Message(_gameServerData);
			message.injectParams();
			
			abRequest(ABTesterConstants.NO_CONDITION_USER, handleNoConditionsResponse, message.messageObject);
			//var abRequest:ServerRequest = new ServerRequest(ABTesterConstants.NO_CONDITION_USER, handleNoConditionsResponse, message.messageObject);
			//abRequest.urlType = ServerRequest.AB_TESTING_URL;
			//_requestHandler.request(abRequest);
		}
		
		private function handleNoConditionsResponse(response:String, failed:Boolean):void
		{
			
		}
		
		/**
		 * 
		 */
		public static function logTestStart(testID:int, conditionID:int, detail:Object = null, callback:Function = null):void
		{
			instance.logTestStart(testID, conditionID, detail, callback);
		}
		
		public function logTestStart(testID:int, conditionID:int, detail:Object = null, callback:Function = null):void
		{
			var message:TestStatusMessage = new TestStatusMessage(testID, conditionID, true, detail, _gameServerData);
			message.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			abRequest(ABTesterConstants.LOG_TEST_START_END, testStartLogged, message.messageObject, null, callbackRequest);
		}
		
		private function testStartLogged(response:String, failed:Boolean, callbackRequest:CallbackRequest):void
		{
			var responseObj:Object = null;
			var callback:Function = callbackRequest.callback;
			if(!failed)
			{
				responseObj = parseResponseData(response);
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			
			if(failed)
			{
				logFailure(ABTesterConstants.LOG_TEST_START_END);
			}
			if(callback != null)
			{
				callback(responseObj, failed);
			}
		}
		
		/**
		 * 
		 */
		public static function logTestEnd(testID:int, conditionID:int, detail:Object = null, callback:Function = null):void
		{
			instance.logTestEnd(testID, conditionID, detail, callback);
		}
		
		public function logTestEnd(testID:int, conditionID:int, detail:Object = null, callback:Function = null):void
		{
			var message:TestStatusMessage = new TestStatusMessage(testID, conditionID, false, detail, _gameServerData);
			message.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			abRequest(ABTesterConstants.LOG_TEST_START_END, testEndLogged, message.messageObject, null, callbackRequest);
		}
		
		private function testEndLogged(response:String, failed:Boolean, callbackRequest:CallbackRequest):void
		{
			var responseObj:Object = null;
			var callback:Function = callbackRequest.callback;
			if(!failed)
			{
				responseObj = parseResponseData(response);
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			if(failed)
			{
				logFailure(ABTesterConstants.LOG_TEST_START_END);
			}
			if(callback != null)
			{
				callback(responseObj, failed);
			}
		}
		
		/**
		 * Log the start of testing on a variable.
		 */
		public static function logConditionVariableStart(testID:int, conditionID:int,
				varID:int, resultID:int, time:Number = -1, detail:Object = null, callback:Function = null):void
		{
			instance.logConditionVariableStart(testID, conditionID, varID, resultID, time, detail, callback);
		}
		
		public function logConditionVariableStart(testID:int, conditionID:int,
				varID:int, resultID:int, time:Number = -1, detail:Object = null, callback:Function = null):void
		{
			var message:ConditionVariableMessage = new ConditionVariableMessage(testID, conditionID, varID, resultID, true, time, detail, _gameServerData);
			message.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			abRequest(ABTesterConstants.LOG_CONDITION_RESULTS, conditionResultsLogged, message.messageObject, null, callbackRequest);
		}
		
		/**
		 * Log the results for a single variable in a test. Use the log test end to log
		 * results for test as a whole.
		 * 
		 * @param testID the id of the test for which to log results.
		 * @param conditionID the id of the condition for which to log results.
		 * @param variableID the id of the condition variable for which to log results.
		 * @param time an optional time parameter for the results. Pass -1 if there is not a time
		 * value associated with the results.
		 * @param detail optional detail information to be logged. 
		 */
		public static function logConditionVariableResults(testID:int, conditionID:int,
				variableID:int, resultID:int, time:Number = -1, detail:Object = null, callback:Function = null):void
		{
			instance.logConditionVariableResults(testID, conditionID, variableID, resultID, time, detail, callback);
		}
		
		public function logConditionVariableResults(testID:int, conditionID:int,
				variableID:int, resultID:int, time:Number = -1, detail:Object = null, callback:Function = null):void
		{
			var message:ConditionVariableMessage = new ConditionVariableMessage(testID, conditionID, variableID, resultID, false, time, detail, _gameServerData);
			message.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			abRequest(ABTesterConstants.LOG_CONDITION_RESULTS, conditionResultsLogged, message.messageObject, null, callbackRequest);
		}
		
		private function conditionResultsLogged(response:String, failed:Boolean, callbackRequest:CallbackRequest):void
		{
			var responseObj:Object = null;
			var callback:Function = callbackRequest.callback;
			if(!failed)
			{
				responseObj = parseResponseData(response);
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			if(failed)
			{
				logFailure(ABTesterConstants.LOG_CONDITION_RESULTS);
			}
			if(callback != null)
			{
				callback(responseObj, failed);
			}
		}
		
		//
		// Log failures.
		//
		
		public function get logFailureCount():int
		{
			return _totalLogFailures;
		}
		
		//Start timer to send log failures to the server.
		private function startLogFailureTimer():void
		{
			if(_timer != null || !_logFailuresEnabled) return;
			
			_timer = new Timer(_logFailureTime);
			_timer.addEventListener(TimerEvent.TIMER, handleSendLogFailures);
			_timer.start();
		}
		
		private function stopLogFailureTimer():void
		{
			if(_timer == null) return;
			
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, handleSendLogFailures);
			_timer = null;
		}
		
		private function handleSendLogFailures(evt:TimerEvent):void
		{
			if(!_logFailuresEnabled) return;
			
			tryLogRequestFailures();
		}
		
		/**
		 * Locally logs a failure which will be attempted to log on the server
		 * when another logging call is made to the server.
		 */
		protected function logFailure(method:String, failCount:int = 1, oldFailure:Boolean = false):void
		{
			if(!_logFailuresEnabled) return;
			
			var failure:FailureRequest = _logFailures[method];
			if(failure == null)
			{
				failure = new FailureRequest(method);
				_logFailures[method] = failure;
			}
			
			startLogFailureTimer();
			failure.incrementCount(failCount);
			
			if(!oldFailure)
			{
				_totalLogFailures += failCount;
			}
		}
		
		/**
		 * Starts the logging of failures to the server.
		 */
		public function tryLogRequestFailures():void
		{
			var failureRequest:FailureRequest = null;
			var failureMethod:String;
			for(var method:String in _logFailures)
			{
				failureMethod = method;
				failureRequest = _logFailures[method];
				break;
			}
			
			if(failureRequest != null)
			{
				delete _logFailures[failureMethod];
				logRequestFailure(failureRequest, handleTryLogFailures);
			}
			else
			{
				stopLogFailureTimer();
			}
		}
		
		protected function logRequestFailure(failure:FailureRequest, callback:Function = null):void
		{
			callback = callback == null ? handleLogFailure : callback;
			var message:Message = new Message(_gameServerData);
			message.injectParams();
			
			//TODO - Log failure specific properties.
			
			request(CGSServerConstants.LOG_FAILURE,  callback, message.messageObject, null, failure);
		}
		
		/**
		 * Try and log logging failures to the server.
		 */
		protected function logRequestFailures():void
		{
			var failures:Array = [];
			for(var method:String in _logFailures)
			{
				failures.push(_logFailures[method]);
			}
			
			for each(var failure:FailureRequest in failures)
			{
				logRequestFailure(failure);
			}
		}
		
		protected function handleLogFailure(response:String, failed:Boolean, failure:FailureRequest):void
		{
			if(failed)
			{
				logFailure(failure.method, failure.count, true);
			}
		}
		
		protected function handleTryLogFailures(response:String, failed:Boolean, failure:FailureRequest):void
		{
			var userFailure:Boolean = false;
			
			//Request to server did not fail.
			if(!failed)
			{
				var responseData:Object = parseResponseData(response);
				userFailure = didRequestFail(responseData);
				
				//Send the remaining failures to the server.
				logRequestFailures();
			}
			
			// If this did fail to log, readd the failure request.
			if(failed)
			{
				logFailure(failure.method, failure.count, true);
			}
		}
		
		//
		// User id request handling.
		//
		
		/**
		 * NOT IMPLEMENTED ON SERVER.
		 * 
		 * Request a CGS UUID from the server which maps to the passed external id. If
		 * the server does not have a mapping for the external id, a new CGS UUID will be
		 * created and a mapping will be created between the UUID and external id.
		 * 
		 * @param callback
		 */
		public static function createUUIDForExternalID(callback:Function, externalID:String):void
		{
			//TODO - Implement once server side is complete.
		}
		
		/**
		 * NOT IMPLEMENTED ON SERVER.
		 * 
		 * Request a CGS UUID which maps to the passed external id.
		 */
		public static function requestUUIDForExternalID(callback:Function, externalID:String):void
		{
			//TODO - Implement once server side is complete.
		}
		
		public static function requestUUID(callback:Function, cacheUUID:Boolean = false, forceName:String = null):void
		{
			instance.requestUUID(callback, cacheUUID, forceName);
		}
		
		/**
		 * Request a CGS user if from the server. This function must be called before any logging
		 * calls are made to the server.
		 * 
		 * @param callback function which will be called when the UUID has been loaded from the server. Callback
		 * should have the signature (uuid:String, failed:Boolen):void. The callback will be called even
		 * if forceName is set or the uid is retrieved from the flash cache.
		 * 
		 * @param cacheUUID indicates if the UUID is saved to the flash cache. If true the UUID will
		 * also be retrieved from the flash cache if it exists. If game is going to support more than 1-player,
		 * this should be set to false and saving the UUID will need to be done in game logic.
		 * 
		 * @param forceName name which should be used for the UUID
		 */
		public function requestUUID(callback:Function, cacheUUID:Boolean = false, forceName:String = null):void
		{
			var uidSet:Boolean = false;
			
			//Handle force name not being null.
			if(forceName != null)
			{
				_gameServerData.uuid = forceName;
				if(cacheUUID)
				{
					saveUUID(forceName);
				}
				uidSet = true;
			}
			
			//Try and get a uuid from the flash cache. If it does not exist,
			//then a uuid will be requested from the server.
			if(cacheUUID)
			{
				var uuid:String = loadUUID();
				if(uuid != null)
				{
					_gameServerData.uuid = uuid;
					uidSet = true;
				}
			}
			
			//Handle callback if the uid has already been set.
			if(uidSet)
			{
				if(callback != null)
				{
					callback(_gameServerData.uuid, false);
				}
				return;
			}
			
			var uuidRequest:UUIDRequest = new UUIDRequest(callback, cacheUUID);
			
			var message:Message = new Message(_gameServerData);
			message.injectGameParams();
			message.injectSKEY();
			
			//Make a generic request to load / create UUID.
			request(CGSServerConstants.UUID_REQUEST, handleUUIDLoaded, message.messageObject, null, uuidRequest);
		}
		
		//Handle the UUID being loaded from the server.
		private function handleUUIDLoaded(vars:String, failed:Boolean, request:UUIDRequest):void
		{
			var uuid:String = "";
			var uuidFailed:Boolean = false;
			
			//Possible that the server responded but returned junk.
			try
			{
				var urlVars:URLVariables = new URLVariables(vars);
				var jsonString:String = urlVars.data;
				var decoder:JSONDecoder = new JSONDecoder(jsonString, true);
				var uuidObject:Object = decoder.getValue();
				uuid = uuidObject.uid;
				_gameServerData.uuid = uuid;
			}
			catch(er:Error)
			{
				uuidFailed = true;
			}
			finally
			{
				var cacheUUID:Boolean = request.cacheUUID;
				if(cacheUUID && !uuidFailed)
				{
					saveUUID(uuid);
				}
				
				var callback:Function = request.callback;
				if(callback != null)
				{
					callback(uuid, failed || uuidFailed);
				}
			}
		}
		
		//Saves UUID to the flash cache.
		protected function saveUUID(uuid:String):void
		{
			Cache.setSave("cgs_uid", uuid);
		}
		
		//Load uuid from the flash cache. Will return null if no uuid exists.
		protected function loadUUID():String
		{
			return Cache.getSave("cgs_uid");
		}
		
		public static function containsUUID():Boolean
		{
			return instance.containsUUID();
		}
		
		public function containsUUID():Boolean
		{
			return Cache.saveExists("cgs_uid");
		}
		
		public static function clearCachedUUID():void
		{
			instance.clearCachedUUID();
		}
		
		/**
		 * Clear uuid stored in the flash cache.
		 */
		public function clearCachedUUID():void
		{
			Cache.deleteSave("cgs_uid");
		}
		
		
		//
		// Action with no quest log handling.
		//
		
		public static function logActionNoQuest(action:ActionNoQuestMessage, callback:Function = null):void
		{
			instance.logActionNoQuest(action);
		}
		
		/**
		 * Log a generic game action which is not associated with a specific quest.
		 */
		public function logActionNoQuest(action:ActionNoQuestMessage, callback:Function = null):void
		{
			//var message:ActionNoQuestMessage = new ActionNoQuestMessage(actionID, actionDetails);
			action.serverData = _gameServerData;
			action.injectParams();
			
			request(CGSServerConstants.ACTION_NO_QUEST, handleActionNoQuestResponse, action.messageObject, null, callback);
		}
		
		private function handleActionNoQuestResponse(response:String, failed:Boolean, callback:Function = null):void
		{
			var responseObj:Object = null;
			if(!failed)
			{
				responseObj = parseResponseData(response);
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			
			if(failed)
			{
				logFailure(CGSServerConstants.ACTION_NO_QUEST);
			}
			
			if(callback != null)
			{
				callback(responseObj, failed);
			}
		}
		
		//
		// Page load handling.
		//
		
		public static function logPageLoad(details:Object = null, callback:Function = null):void
		{
			instance.logPageLoad(details);
		}
		
		public function logPageLoad(details:Object = null, callback:Function = null):void
		{
			var message:PageloadMessage = new PageloadMessage(details, _gameServerData);
			
			//Inject required parameters for page load.
			message.injectParams();
			message.injectEventID(true);
			
			request(CGSServerConstants.PAGELOAD, handlePageLoadResponse, message.messageObject, null, callback);
		}
		
		private function handlePageLoadResponse(response:String, failed:Boolean, callback:Function = null):void
		{
			//Update logging settings.
			var responseObj:Object = null;
			if(!failed)
			{
				responseObj = parseResponseData(response);
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			
			if(failed)
			{
				logFailure(CGSServerConstants.PAGELOAD);
			}
			
			if(callback != null)
			{
				callback(responseObj, failed);
			}
		}
		
		//
		// User feedback handling.
		//
		
		public static function submitUserFeedback(feedback:UserFeedbackMessage, callback:Function = null):void
		{
			instance.submitUserFeedback(feedback, callback);
		}
		
		/**
		 * Submit user feedback to the server.
		 */
		public function submitUserFeedback(feedback:UserFeedbackMessage, callback:Function = null):void
		{
			//Inject required data into the feedback message.
			feedback.serverData = _gameServerData;
			feedback.injectParams();
			
			var req:CallbackRequest = new CallbackRequest(callback);
			
			request(CGSServerConstants.USER_FEEDBACK, handleUserInfoSentMessage, feedback.messageObject, null, req);
		}
		
		protected function handleUserInfoSentMessage(response:String, failed:Boolean, callbackRequest:CallbackRequest):void
		{
			var responseObj:Object = null;
			var callback:Function = callbackRequest.callback;
			if(!failed)
			{
				responseObj = parseResponseData(response);
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			
			if(failed)
			{
				logFailure(CGSServerConstants.USER_FEEDBACK);
			}
			
			if(callback != null)
			{
				callback(response, failed);
			}
		}
		
		//
		// Save / load data handling.
		//
		
		//
		// DQID handling.
		//
		
		private function getLocalDQID():int
		{
			return ++_localQuestID;
		}
		
		private function get currentLocalDQID():int
		{
			return _localQuestID;
		}
		
		public function get lastLocalDQID():int
		{
			return _lastBufferedMessage != null ? _lastBufferedMessage.getLocalDQID() : -1;
		}
		
		private function get currentQuestID():int
		{
			return _lastBufferedMessage != null ? _lastBufferedMessage.getQuestID() : 0;
		}
		
		private function get currentDQID():String
		{
			return _lastBufferedMessage != null ? _lastBufferedMessage.dqid : "";
		}
		
		//Get a server dqid from a local dqid.
		private function getDQID(localDQID:int = -1):String
		{
			var message:BufferedMessage = localDQID < 0 ? _lastBufferedMessage : _bufferedMessages[localDQID];
			
			return message != null ? message.dqid : null;
		}
		
		//Get the buffered message for the given localDQID. If the dqid = -1
		//then the last buffered message created will be returned.
		private function getBufferedMessage(localDQID:int):BufferedMessage
		{
			return localDQID < 0 ? _lastBufferedMessage : _bufferedMessages[localDQID];
		}
		
		public static function requestDQID(callback:Function, localDQID:int = -1):void
		{
			instance.requestDQID(callback);
		}
		
		/**
		 * Request a dqid from the server. logQuestStart can be used in lieu of this function 
		 * as it will request a DQID from the server and send quest start message
		 * and any quest actions when the server returns a dqid.
		 * 
		 * @param callback function which will be called when the server responds with DQID.
		 * The function should have the signature: (dqid:String, failed:Boolean):void.
		 * 
		 * @param localDQID a local unique quest id used to ensure the quest logging actions
		 * are logged with the correct DQID returned from the server. If an id is not
		 * passed one will be created.
		 * 
		 * @return int the localDQID which is created for the dqid request. This value
		 * is not needed if logQuestStart is used in lieu of logQuestStartWithDQID.
		 */
		public function requestDQID(callback:Function, localDQID:int = -1):int
		{
			if(localDQID == -1)
			{
				localDQID = getLocalDQID();
			}
			
			var dqidRequest:DQIDRequest = new DQIDRequest(localDQID, callback);
			
			var message:Message = new Message(_gameServerData);
			message.injectGameParams();
			message.injectSKEY();
			
			request(CGSServerConstants.DQID_REQUEST, handleDQIDResponse, message.messageObject, null, dqidRequest);
			
			return localDQID;
		}
		
		//Handle the response from the server to get a dynamic quest id.
		protected function handleDQIDResponse(data:String, failed:Boolean, dqidRequest:DQIDRequest):void
		{
			var callback:Function = dqidRequest.callback;
			var dqid:String = "";
			var dqidFailed:Boolean = false;
			try
			{
				//This will cause an error if the server fails.
				var urlVars:URLVariables = new URLVariables(data);
				var decoder:JSONDecoder = new JSONDecoder(urlVars.data, true);
				var jsonObj:Object = decoder.getValue();
				
				dqid = jsonObj.dqid;
			}
			catch(er:Error)
			{
				dqidFailed = true;
				dqid = null;
			}
			finally
			{
				//Handle sending any messages which required the dqid.
				if(!dqidFailed || !failed)
				{
					var localID:int = dqidRequest.localLevelID;
					_dynamicQuestIDMap[localID] = dqid;
					updateBufferMessageDQID(dqid, localID);
					
					sendQueuedMessages(localID, dqid);
				}
				if(callback != null)
				{
					callback(dqid, failed);
				}
			}
		}
		
		private function updateBufferMessageDQID(dqid:String, localDQID:int):void
		{
			var message:BufferedMessage = _bufferedMessages[localDQID];
			if(message == null) return;
			
			if(message.getLocalDQID() == localDQID)
			{
				message.setDQID(dqid);
			}
		}
		
		//Send any messages which have been waiting for the server to send
		//back a dynamic quest id.
		protected function sendQueuedMessages(localDQID:int, dqid:String):void
		{
			//Handle the messages waiting for the dynamic id to be set.
			var queueMessages:Array = _waitingMessages[localDQID];
			delete _waitingMessages[localDQID];
			
			if(queueMessages == null) return;
			
			var message:QuestRequest;
			var requestFunction:Function;
			
			for(var idx:int = queueMessages.length-1; idx >= 0; idx--)
			{
				message = queueMessages[idx];
				message.setDQID(dqid);
				requestFunction = message.requestCallback;
				if(requestFunction != null)
				{
					requestFunction(message);
				}
			}
		}
		
		//
		// Quest creation.
		//
		
		/**
		 * Create a quest on the server. This allows for actions to be logged for the quest id that
		 * is created by the server due to this request.
		 * 
		 * @param questName the name of the quest.
		 * @param questTypeID the id for the quest type.
		 * @param callback should have the signature (questID:int, failed:Boolean):void. Failed will be true
		 * if the request to the server failed for any reason, the questID will be -1 in the case.
		 */
		public static function createQuest(questName:String, questTypeID:int, callback:Function = null):void
		{
			instance.createQuest(questName, questTypeID, callback);
		}
		
		public function createQuest(questName:String, questTypeID:int, callback:Function = null):void
		{
			var message:CreateQuestRequest = new CreateQuestRequest(questName, questTypeID);
			message.injectParams();
			
			var callbackData:CallbackRequest = new CallbackRequest(callback);
			
			request(CGSServerConstants.CREATE_QUEST, handleCreateQuestResponse, message.messageObject, null, callbackData);
		}
		
		private function handleCreateQuestResponse(data:String, failed:Boolean, request:ServerRequest):void
		{
			var callback:Function = request.callback;
			if(failed)
			{
				if(callback != null)
				{
					callback(-1, true);
				}
				logFailure(CGSServerConstants.CREATE_QUEST);
			}
			else
			{
				try
				{
					var urlVariables:URLVariables = new URLVariables(data);
					var decoder:JSONDecoder = new JSONDecoder(urlVariables.data, true);
					var jsonObject:Object = decoder.getValue();
					
					var questData:Object = jsonObject.rdata;
					var qid:int = questData.qid;
					if(callback != null)
					{
						callback(qid, false);
					}
				}
				catch(er:Error)
				{
					if(callback != null)
					{
						callback(-1, true);
					}
				}
			}
		}
		
		//
		// Quest logging.
		//
		
		//Create a new buffered message with the given quest parameters.
		private function createQuestMessageBuffer(questID:int, localDQID:int, dqid:String = null):BufferedMessage
		{
			_lastBufferedMessage = new BufferedMessage(_gameServerData);
			_lastBufferedMessage.setLocalDQID(localDQID);
			_lastBufferedMessage.setQuestID(questID);
			_lastBufferedMessage.setDQID(dqid);
			
			if(!_bufferedMessages.hasOwnProperty(localDQID))
			{
				_openQuests++;
			}
			_bufferedMessages[localDQID] = _lastBufferedMessage;
			
			return _lastBufferedMessage;
		}
		
		//Removes quest action buffer. Will set the lastBuffered message to null if it is removed.
		private function removeQuestMessageBuffer(localDQID:int = -1):void
		{
			if(localDQID < 0)
			{
				localDQID = currentLocalDQID;
			}
			if(_bufferedMessages.hasOwnProperty(localDQID))
			{
				_openQuests--;
				var message:BufferedMessage = _bufferedMessages[localDQID];
				delete _bufferedMessages[localDQID];
				
				if(message == _lastBufferedMessage)
				{
					_lastBufferedMessage = null;
					updateLastBufferedMessage();
				}
			}
		}
		
		private function updateLastBufferedMessage():void
		{
			for(var localDQID:String in _bufferedMessages)
			{
				_lastBufferedMessage = _bufferedMessages[localDQID];
				break;
			}
		}
		
		/**
		 * Log the start of a quest with the given dqid.
		 */
		public static function logQuestStartWithDQID(questID:int, dqid:String, details:Object, aeSeqID:String = null):int
		{
			return instance.logQuestStartWithDQID(questID, dqid, details, aeSeqID);
		}
		
		/**
		 * Log the start of a new quest with the specified dqid which has already been retrieved from the server.
		 * If a dqid is needed from the server, use logQuestStart.
		 * When the quest is complete, the logQuestEnd must be called.
		 * 
		 * @param questID the quest id as defined on the server.
		 * @param dqid the dynamic quest id which has been requested from the server.
		 * @param details an object which contains name/value pairs of properties to be stored on the server.
		 * @param levelID an optional server paramter which can be used to group quests into a level.
		 * @param aeSeqID an optional id which may be needed if the Assessment Engine is involved with the game.
		 * @param localDQID optional parameter for a local unique quest id.
		 * 
		 * @return localDQID which can be used to log actions for the quest. If your game only has one active quest
		 * at a time, you do not need to pass the localDQID to log actions.
		 */
		public function logQuestStartWithDQID(questID:int, dqid:String, details:Object, aeSeqID:String = null, localDQID:int = -1):int
		{
			var newLocalDQID:int = localDQID < 0 ? getLocalDQID() : localDQID;
			createQuestMessageBuffer(questID, newLocalDQID, dqid);
			
			var questMessage:QuestMessage = new QuestMessage(questID, details, true, aeSeqID, dqid, _gameServerData);
			var request:QuestRequest = new QuestRequest(null, questMessage, sendQuestMessage, _questGameID);
			
			//Send the quest message.
			sendQuestMessage(request);
			
			resetActionBufferHandler();
			startActionBufferHandler();
			
			return newLocalDQID;
		}
		
		private function sendQuestMessage(message:QuestRequest):void
		{
			/*var questMessage:IQuestMessage = message.questMessage;
			
			//Inject required parameters into the quest message.
			questMessage.injectParams();
			if(_questGameID >= 0)
			{
				questMessage.addProperty("gid", _questGameID);
			}*/
			
			request(CGSServerConstants.QUEST_START, handleQuestStartResponse, message.questMessageObject, null, message);
		}
		
		private function sendLegacyQuestMessage(message:QuestRequest):void
		{
			/*var questMessage:IQuestMessage = message.questMessage;
			
			//Inject required parameters into the quest message.
			questMessage.injectParams();
			if(_questGameID >= 0)
			{
				questMessage.addProperty("gid", _questGameID);
			}*/
			
			request(CGSServerConstants.LEGACY_QUEST_START, handleQuestStartResponse, message.questMessageObject, null, message);
		}
		
		private function handleQuestStartResponse(response:String, failed:Boolean, questRequest:QuestRequest):void
		{
			var callback:Function = questRequest.callback;
			var responseObj:Object = parseResponseData(response);
			
			if(responseObj != null)
			{
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			else
			{
				failed = true;
			}
			
			if(failed)
			{
				logFailure(CGSServerConstants.QUEST_START);
			}
			if(callback != null)
			{
				callback(questRequest.getDQID(), failed);
			}
		}
		
		/**
		 * Log the start of a quest. This assumes that there is no valid dqid for the quest and
		 * one will be requested from the server.
		 * When the quest is complete, the logQuestEnd must be called.
		 * 
		 * @param questID the id of the quest as defined on the server.
		 * @param details properties to be logged with the quest start.
		 * @param callback function to be called when the dqid is returned from the server.
		 * Function should have the signature of (dqid:String, failed:Boolean).
		 * @param levelID an optional server paramter which can be used to group quests into a level.
		 * @param aeSeqID used in conjection with the Assessment engine.
		 * @param localDQID optional parameter for a local unique quest id.
		 * 
		 * @return localDQID which can be used to log actions for the quest. If your game only has one active quest
		 * at a time, you do not need to pass the localDQID to log actions.
		 */
		public static function logQuestStart(questID:int, details:Object, callback:Function = null, aeSeqID:String = null, localDQID:int = -1):int
		{
			return instance.logQuestStart(questID, details, callback, aeSeqID, localDQID);
		}
		
		public function logQuestStart(questID:int, details:Object, callback:Function = null, aeSeqID:String = null, localDQID:int = -1):int
		{
			return localLogQuestStart(questID, details, callback, aeSeqID, localDQID);
		}
		
		private function localLogQuestStart(questID:int, details:Object, callback:Function = null, aeSeqID:String = null, localDQID:int = -1, legacy:Boolean = false):int
		{
			//Create a start quest message.
			var questMessage:QuestMessage = new QuestMessage(questID, details, true, aeSeqID, null, _gameServerData);
			var request:QuestRequest = new QuestRequest(callback, questMessage, legacy ? sendLegacyQuestMessage : sendQuestMessage, _questGameID);
			
			localDQID = requestDQID(null, localDQID);
			
			createQuestMessageBuffer(questID, localDQID);
			
			//Store the quest message to be sent once the dqid is returned.
			queueQuestMessage(request, localDQID);
			
			resetActionBufferHandler();
			startActionBufferHandler();
			
			return localDQID;
		}
		
		/**
		 * Log a quest start using the legacy method on the server. This method should not be used, @see logQuestStart for
		 * updated server method.
		 * 
		 * @param questID the id of the quest as defined on the server.
		 * @param details properties to be logged with the quest start.
		 * @param callback function to be called when the dqid is returned from the server.
		 * Function should have the signature of (dqid:String, failed:Boolean).
		 * @param levelID an optional server paramter which can be used to group quests into a level.
		 * @param aeSeqID used in conjection with the Assessment engine.
		 * @param localDQID optional parameter for a local unique quest id.
		 * 
		 * @return localDQID which can be used to log actions for the quest. If your game only has one active quest
		 * at a time, you do not need to pass the localDQID to log actions.
		 * @deprecated
		 */
		public static function legacyLogQuestStart(questID:int, details:Object, callback:Function = null, aeSeqID:String = null, localDQID:int = -1):int
		{
			return instance.legacyLogQuestStart(questID, details, callback, aeSeqID, localDQID);
		}
		
		public function legacyLogQuestStart(questID:int, details:Object, callback:Function = null, aeSeqID:String = null, localDQID:int = -1):int
		{
			return localLogQuestStart(questID, details, callback, aeSeqID, localDQID, true);
		}
		
		/**
		 * Queue a message to be sent once the dqid has been set.
		 * 
		 * @param localDQID the local dqid for the quest.
		 * @param message
		 */
		protected function queueQuestMessage(message:QuestRequest, localDQID:int = -1):void
		{
			if(localDQID < 0)
			{
				localDQID = _lastBufferedMessage != null ? _lastBufferedMessage.getLocalDQID() : localDQID;
			}
			
			//Check if there is a valid dqid for the quest and send message to server if there is.
			if(_dynamicQuestIDMap.hasOwnProperty(localDQID))
			{
				message.setDQID(_dynamicQuestIDMap[localDQID]);
				sendQuestMessage(message);
				return;
			}
			
			var messages:Array = _waitingMessages[localDQID];
			if(messages == null)
			{
				messages = new Array();
				_waitingMessages[localDQID] = messages;
			}
			
			messages.push(message);
		}
		
		/**
		 * Log the end of a quest. This also causes the buffer handler to be stopped and wait for the next quest start message.
		 * After this method is called no more actions should be logged for the quest.
		 * 
		 * @param questID the id of the quest to end.
		 * @param details the information to be logged at the end of quest.
		 * @param callback function that will be called when the log quest end is logged on the server.
		 * @param localDQID only needed if game has multiple open quests.
		 */
		public static function logQuestEnd(questID:int, details:Object, callback:Function = null, localDQID:int = -1):void
		{
			instance.logQuestEnd(questID, details, callback, localDQID);
		}
		
		public function logQuestEnd(questID:int, details:Object, callback:Function = null, localDQID:int = -1):void
		{
			//Send the quest end message.
			var message:QuestMessage = new QuestMessage(questID, details, false, null, null, _gameServerData);
			var request:QuestRequest = new QuestRequest(callback, message, sendQuestMessage, _questGameID);
			message.setDQID(getDQID(localDQID));
			
			//Flush the last actions in the buffer.
			flushActionsOptions(true, localDQID);
			instance.resetActionBufferHandler();
			instance.stopActionBufferHandler();
			
			if(message.isDQIDValid)
			{
				sendQuestMessage(request);
			}
			else
			{
				queueQuestMessage(request, localDQID);
			}
		}
		
		//
		// Quest action handling.
		//
		
		/**
		 * Log a quest action. If the action is not bufferable, it will be sent as it own message to the server.
		 * This will also cause all previosly buffered actions to be flushed to the server regardless of the forceFlush parameter.
		 * 
		 * @param action the client action to be logged on the server. Can not be null.
		 * @param localDQID the localDQID for the quest that this action should be logged under. Only
		 * needed if there is more than one active quest for which actions are being logged.
		 * @param forceFlush indicates if the actions buffer should be flushed after the passed
		 * action is added to the actions buffer.
		 */
		public static function logQuestAction(action:ClientAction, localDQID:int = -1, forceFlush:Boolean = false):void
		{
			instance.logQuestAction(action, localDQID, forceFlush);
		}
		
		public function logQuestAction(action:ClientAction, localDQID:int = -1, forceFlush:Boolean = false):void
		{
			var bufferMessage:BufferedMessage = getBufferedMessage(localDQID);
			if(action.isBufferable())
			{
				bufferMessage.addAction(action);
			}
			else
			{
				//Flush the current actions.
				flushActions(localDQID);
				
				bufferMessage.addAction(action);
				forceFlush = true;
			}
			
			if(forceFlush)
			{
				flushActions(localDQID);
			}
		}
		
		//
		// Action buffer handling.
		//
		
		/**
		 * Pause the automatic flushing of actions to the server.
		 */
		public static function pauseActionBufferHandler():void
		{
			instance.pauseActionBufferHandler();
		}
		
		public function pauseActionBufferHandler():void
		{
			if(_actionBufferHandler == null) return;
			
			_actionBufferHandler.stop();
		}
		
		/**
		 * Resume the automatic flushing of actions to the server.
		 */
		public static function resumeActionBufferHandler():void
		{
			instance.resumeActionBufferHandler();
		}
		
		public function resumeActionBufferHandler():void
		{
			if(_actionBufferHandler == null) return;
			
			_actionBufferHandler.start();
		}
		
		private function resetActionBufferHandler():void
		{
			if(_actionBufferHandler == null)
			{
				_actionBufferHandler = new _actionBufferHandlerClass();
				_actionBufferHandler.listener = this;
				_actionBufferHandler.setProperties(CGSServerConstants.bufferFlushIntervalStart, CGSServerConstants.bufferFlushIntervalEnd, CGSServerConstants.bufferFlushRampTime);
			}
			
			_actionBufferHandler.reset();
		}
		
		private function startActionBufferHandler():void
		{
			if(_actionBufferHandler == null)
			{
				_actionBufferHandler = new _actionBufferHandlerClass();
				_actionBufferHandler.listener = this;
				_actionBufferHandler.setProperties(CGSServerConstants.bufferFlushIntervalStart, CGSServerConstants.bufferFlushIntervalEnd, CGSServerConstants.bufferFlushRampTime);
			}
			
			_actionBufferHandler.start();
		}
		
		private function stopActionBufferHandler():void
		{
			if(_actionBufferHandler == null) return;
			
			_actionBufferHandler.stop();
		}
		
		public static function flushActions(localDQID:int = -1, callback:Function = null):void
		{
			instance.flushActions(localDQID, callback);
		}
		
		/**
		 * Sends all buffered actions to the server.
		 * 
		 * @param localDQID the localDQID for which actions should be flushed. If
		 * -1 is passed, actions for all quests are flushed to the server.
		 */
		public function flushActions(localDQID:int = -1, callback:Function = null):void
		{
			flushActionsOptions(false, localDQID, callback);
		}
		
		private static function flushActionsOptions(questEnd:Boolean, localDQID:int = -1, callback:Function = null):void
		{
			instance.flushActionsOptions(questEnd, localDQID, callback);
		}
		
		/**
		 * Sends all buffered actions to the server. This create a new empty action buffer.
		 */
		private function flushActionsOptions(questEnd:Boolean, localDQID:int = -1, callback:Function = null):void
		{
			if(localDQID < 0)
			{
				flushAllActions(questEnd, callback);
			}
			else
			{
				flushQuestActionsByID(questEnd, localDQID, callback);
			}
		}
		
		//Flush actions for all buffered messages.
		private function flushAllActions(questEnd:Boolean, callback:Function = null):void
		{
			for(var localDQID:String in _bufferedMessages)
			{
				flushQuestActions(questEnd, _bufferedMessages[localDQID], callback);
			}
		}
		
		private function flushQuestActionsByID(questEnd:Boolean, localDQID:int, callback:Function = null):void
		{
			flushQuestActions(questEnd, getBufferedMessage(localDQID), callback);
		}
		
		//Sends quest actions to the server and creates a new buffered message if the quest has not ended.
		private function flushQuestActions(questEnd:Boolean, flushBuffer:BufferedMessage, callback:Function = null):void
		{
			if(flushBuffer == null) return;
			
			if(!flushBuffer.isDQIDValid())
			{
				if(_dynamicQuestIDMap.hasOwnProperty(flushBuffer.getLocalDQID()))
				{
					flushBuffer.setDQID(_dynamicQuestIDMap[flushBuffer.getLocalDQID()]);
				}
			}
			
			//Handle creating the next buffered message or deleting the message if the quest has ended.
			if(questEnd)
			{
				removeQuestMessageBuffer(flushBuffer.getLocalDQID());
				//delete _bufferedMessages[flushBuffer.getLocalDQID()];
			}
			//Only create a new action buffer if there are actions that need to be sent to server.
			else if(flushBuffer.getActionCount() > 0)
			{
				createQuestMessageBuffer(flushBuffer.getQuestID(), flushBuffer.getLocalDQID(), flushBuffer.dqid);
			}
			
			//Do not send actions if there are none to send.
			if(flushBuffer.getActionCount() == 0)
			{
				return;
			}
			
			var request:QuestRequest = new QuestRequest(callback, flushBuffer, sendActionsToServer, _questGameID);
			
			//Handle sending the actions to the server.
			if(flushBuffer.isDQIDValid())
			{
				sendActionsToServer(request);
			}
			else
			{
				queueQuestMessage(request, flushBuffer.getLocalDQID());
			}
		}
		
		//Send buffered actions to the server. The passed message should not be reused as
		//this can lead to duplicate or dropped actions.
		private function sendActionsToServer(qRequest:QuestRequest):void
		{
			/*var message:IQuestMessage = qRequest.questMessage;
			message.injectParams();
			if(_questGameID >= 0)
			{
				message.addProperty("gid", _questGameID);
			}*/

			request(CGSServerConstants.QUEST_ACTIONS, handleActionResponse, qRequest.questMessageObject, null, qRequest);
		}
		
		//Does not track loader for any context on response.
		protected function handleActionResponse(reponse:String, failed:Boolean, qRequest:QuestRequest):void
		{
			var message:BufferedMessage = qRequest.questMessage as BufferedMessage;
			if(failed)
			{
				handleFailedActions(message);
				return;
			}
			
			var data:Object = parseResponseData(reponse);
			failed = didRequestFail(data);
			
			if(failed)
			{
				handleFailedActions(message);
			}
			
			updateLoggingLoad(data);
			
			var callback:Function = qRequest.callback;
			if(callback != null)
			{
				callback(data, failed);
			}
		}
		
		private function updateLoggingLoad(jsonObj:Object):void
		{
			if(jsonObj == null) return;
			
			if(jsonObj.hasOwnProperty("tload"))
			{
				var newLoggingLoad:int = jsonObj.tload;
				if(_serverLoggingPriority != newLoggingLoad)
				{
					_serverLoggingPriority = newLoggingLoad;
					if(_logPriorityChangeCallback != null)
					{
						_logPriorityChangeCallback(_serverLoggingPriority);
					}
				}
			}
		}
		
		private function handleFailedActions(message:BufferedMessage):void
		{
			//Handle actions that failed logging to the server.
			logFailure(CGSServerConstants.QUEST_ACTIONS, message.getActionCount());
			
			//TODO - Add local caching of actions to be sent later?
		}
		
		private function handleFailedRequest(request:IServerRequest):void
		{
			//TODO - What should this do? Save the request to be sent later?
		}
		
		//
		// Score saving and loading.
		//
		
		/**
		 * Save a score for the user. This score is saved with the current
		 * quest id and dqid which have been set by the startQuest call.
		 * 
		 * @param score the score for the current quest.
		 * @param callback function to be called when the score has been logged on the server.
		 * @param localDQID
		 */
		public static function logQuestScore(score:Number, callback:Function = null, localDQID:int = -1):void
		{
			instance.logQuestScore(score, callback, localDQID);
		}
		
		public function logQuestScore(score:Number, callback:Function = null, localDQID:int = -1):void
		{
			var scoreMessage:ScoreMessage = new ScoreMessage(score, _gameServerData);
			scoreMessage.setQuestID(currentQuestID);
			
			var scoreRequest:QuestRequest = new QuestRequest(callback, scoreMessage, sendScoreMessage, _questGameID);
			
			var message:BufferedMessage = getBufferedMessage(localDQID);
			
			if(message.isDQIDValid())
			{
				scoreMessage.setDQID(currentDQID);
				sendScoreMessage(scoreRequest);
			}
			else
			{
				queueQuestMessage(scoreRequest, message.getLocalDQID());
			}
		}
		
		private function sendScoreMessage(qRequest:QuestRequest):void
		{
			//var scoreMessage:IQuestMessage = qRequest.questMessage;
			//scoreMessage.injectParams();
			
			request(CGSServerConstants.SAVE_SCORE, handleSaveScoreResponse, qRequest.questMessageObject, null, qRequest);
		}
		
		/**
		 * Save a user score which is not associated with a single quest. This score
		 * could be the total score for several quests or game levels. The passed quest id
		 * should be unique and can be used to differentiate this score value from other player scores.
		 * 
		 * @param score the score for the current quest.
		 * @param questID the unique id which indentifies the passed score.
		 */
		public static function logScore(score:Number, questID:int, callback:Function = null):void
		{
			instance.logScore(score, questID, callback);
		}
		
		public function logScore(score:Number, questID:int, callback:Function = null):void
		{
			var scoreMessage:ScoreMessage = new ScoreMessage(score, _gameServerData);
			scoreMessage.setQuestID(questID);
			scoreMessage.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			request(CGSServerConstants.SAVE_SCORE, handleSaveScoreResponse, scoreMessage.messageObject, null, callbackRequest);
		}
		
		private function handleSaveScoreResponse(vars:String, failed:Boolean, qRequest:CallbackRequest = null):void
		{
			var callback:Function = null;
			if(qRequest != null)
			{
				callback = qRequest.callback;
			}
			
			var responseObj:Object = null;
			if(!failed)
			{
				responseObj = parseResponseData(vars);
				updateLoggingLoad(responseObj);
				failed = didRequestFail(responseObj);
			}
			
			if(callback != null)
			{
				callback(responseObj, failed);
			}
		}
		
		/**
		 * Request all of the scores for the given quest id.
		 */
		public static function requestScoresByQuestID(questID:int):void
		{
			instance.requestScores();
		}
		
		public function requestScores():void
		{
			//TODO - Implement once server has functionality implemented.
		}
		
		//
		// Saving and loading game data.
		//
		
		/**
		 * Save the passed data object to the server with the passed data id.
		 * 
		 * @param dataID the id which should be associated with the passed data object.
		 * @param data the object to be saved on the server. This object will be converted
		 * to a JSON encoded string.
		 * @param callback an optional function to be called when the data has been successfully loaded to
		 * the server. The function should have the signature (dataID:int, failed:Boolean).
		 */
		public static function saveGameData(dataID:String, data:*, callback:Function = null):void
		{
			instance.saveGameData(dataID, data, callback);
		}
		
		public function saveGameData(dataID:String, data:*, callback:Function = null):void
		{
			var message:Message = new Message(_gameServerData);
			message.addProperty("udata_id", dataID);
			
			if(data != null)
			{
				var encoder:JSONEncoder = new JSONEncoder(data);
				message.addProperty("data_detail", encoder.getString());
			}
			
			message.injectParams();
			
			var dataRequest:GameDataRequest = new GameDataRequest(callback, dataID);
			
			request(CGSServerConstants.SAVE_GAME_DATA, handleGameDataSaved, message.messageObject, null, dataRequest);
		}
		
		//Handle logging adjustment
		private function handleGameDataSaved(data:String, failed:Boolean, dataRequest:GameDataRequest):void
		{
			var callback:Function = dataRequest.callback;
			var dataID:String = dataRequest.dataID;
			
			if(!failed)
			{
				var dataObj:Object = parseResponseData(data);
				updateLoggingLoad(dataObj);
				failed = didRequestFail(dataObj);
			}
			
			if(callback != null)
			{
				callback(dataID, failed);
			}
		}
		
		public static function loadGameData(callback:Function):void
		{
			instance.loadGameData(callback);
		}
		
		/**
		 * Loads all saved data for the current user.
		 * 
		 * @param callback function which will be called when the users game data
		 * has been loaded from the server. Function should have signature (data:UserGameData, failed:Boolean):void.
		 */
		public function loadGameData(callback:Function):void
		{
			var message:Message = new Message(_gameServerData);
			message.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			request(CGSServerConstants.LOAD_USER_GAME_DATA, handleGameDataLoaded, message.messageObject, null, callbackRequest);
		}
		
		private function handleGameDataLoaded(data:String, failed:Boolean, callbackRequest:CallbackRequest):void
		{
			var callback:Function = callbackRequest.callback;
			var gameData:UserGameData = null;
			if(!failed)
			{
				var dataObj:Object = parseResponseData(data);
				var response:UserGameDataRequest = new UserGameDataRequest();
				response.data = dataObj;
				gameData = response.userGameData;
			}
			
			if(callback != null)
			{
				callback(gameData, failed);
			}
		}
		
		/**
		 * Load a users game data from the server.
		 * 
		 * @param dataID the id of the data to load from the server.
		 * @param callback the function to be called when the data is loaded from the server.
		 * callback should have the signature (data:UserDataChunk, failed:Boolean).
		 */
		public function loadGameDataByID(dataID:String, callback:Function):void
		{
			var message:Message = new Message(_gameServerData);
			message.addProperty("udata_id", dataID);
			message.injectParams();
			
			var callbackRequest:GameDataRequest = new GameDataRequest(callback, dataID);
			
			request(CGSServerConstants.LOAD_GAME_DATA, handleGameDataLoadByID, message.messageObject, null, callbackRequest);
		}
		
		//Handle loading of data from the server.
		private function handleGameDataLoadByID(dataString:String, failed:Boolean, request:GameDataRequest):void
		{
			var callback:Function = request.callback;
			
			//Convert the data to an object.
			var dataChunk:UserDataChunk = null;
			if(!failed)
			{
				var data:Object = parseResponseData(dataString);
				var response:UserDataChunkResponse = new UserDataChunkResponse();
				response.data = data;
				dataChunk = response.dataChunk;
			}
			
			if(callback != null)
			{
				callback(dataChunk, failed);
			}
		}
		
		//
		// Terms of service handling.
		//
		
		public static function saveTOSStatus(accepted:Boolean, callback:Function = null):void
		{
			instance.saveTOSStatus(accepted, callback);
		}
		
		public function saveTOSStatus(accepted:Boolean, callback:Function = null):void
		{
			saveGameData(CGSServerConstants.TOS_DATA_ID, accepted, callback);
		}
		
		public static function loadTOSStatus(callback:Function):void
		{
			instance.loadTOSStatus(callback);
		}
		
		public function loadTOSStatus(callback:Function):void
		{
			var message:Message = new Message(_gameServerData);
			message.addProperty("udata_id", CGSServerConstants.TOS_DATA_ID);
			message.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback);
			
			request(CGSServerConstants.LOAD_GAME_DATA, handleGameDataLoadByID, message.messageObject, null, callbackRequest);
		}
		
		private function handleLoadTOSStatus(dataString:String, failed:Boolean, request:CallbackRequest):void
		{
			var callback:Function = request.callback;
			
			//Convert the data to an object.
			var data:Boolean = false;
			if(!failed)
			{
				data = parseResponseData(dataString);
				_userAcceptedTOS = data;
			}
			
			if(callback != null)
			{
				callback(data, failed);
			}
		}
		
		//
		// Generic data loading methods.
		//
		
		public static function requestLoggingData(method:String, dataParams:Object, callback:Function, returnType:String = "TEXT"):void
		{
			instance.requestLoggingData(method, dataParams, callback, returnType);
		}
		
		public function requestLoggingData(method:String, dataParams:Object, callback:Function, returnType:String = "TEXT"):void
		{
			var message:Message = new Message(_gameServerData);
			for(var key:String in dataParams)
			{
				message.addProperty(key, dataParams[key]);
			}
			message.injectParams();
			
			var callbackRequest:CallbackRequest = new CallbackRequest(callback, returnType);
			
			request(method, handleLoggingDataLoaded, message.messageObject, null, callbackRequest);
		}
		
		//TODO - Update to allow for the return data type to be specified, test, json object.
		private function handleLoggingDataLoaded(response:String, failed:Boolean, callbackRequest:CallbackRequest):void
		{
			var returnData:* = parseResponseData(response, callbackRequest.returnDataType);
			
			var callback:Function = callbackRequest.callback;
			if(callback != null)
			{
				callback(returnData, failed);
			}
		}
		
		//
		// Helper functions.
		//
		
		/**
		 * Parse the data returned from the server
		 * Will return null if the parse fails.
		 */
		private function parseResponseData(rawData:String, returnDataType:String = "JSON"):*
		{
			var data:* = null;
			try
			{
				var urlVars:URLVariables = new URLVariables(rawData);
				var dataString:String = urlVars.data;
				if(returnDataType == "JSON")
				{
					var decoder:JSONDecoder = new JSONDecoder(dataString, true);
					data = decoder.getValue();
				}
				else
				{
					data = dataString;
				}
				
				//Handle the server data for the response.
				if(urlVars.hasOwnProperty("server_data"))
				{
					var serverDataRaw:String = urlVars.serverData;
					decoder = new JSONDecoder(serverDataRaw, true);
					var serverData:Object = decoder.getValue();
					
					updateLoggingLoad(serverData);
					
					if(serverData.hasOwnProperty("pvid"))
					{
						_currentResponseVersion = serverData.pvid;
					}
					else
					{
						_currentResponseVersion = 0;
					}
				}
				else
				{
					_currentResponseVersion = 0;
					if(returnDataType == "JSON")
					{
						updateLoggingLoad(data);
					}
				}
			}
			catch(er:Error)
			{
				//Unable to parse the returned data from the server. Server must have failed.
			}
			
			return data;
		}
		
		private function didRequestFail(dataObject:Object):Boolean
		{
			if(dataObject == null) return true;
			
			var failed:Boolean = true;
			if(dataObject.hasOwnProperty("tstatus"))
			{
				failed = dataObject.tstatus != "t";
			}
			
			return failed;
		}
		
		/**
		 * Get timestamp to prevent URL caching.
		 */
		public static function getTimeStamp():String
		{
			var timeStamp:Number = new Date().getTime();
			return timeStamp.toString(36);
		}
		
		//
		// External timer handling.
		//
		
		/**
		 * External timer handling. Can be used for custom buffer flush handling.
		 * This allows the buffer flush handler to be paused with a global timer.
		 * 
		 * @param delta time change in seconds.
		 */
		public function onTick(delta:Number):void
		{
			if(_actionBufferHandler != null)
			{
				_actionBufferHandler.onTick(delta);
			}
		}
	}
}