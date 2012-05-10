package cgs.server.logging.messages
{
	import cgs.server.logging.GameServerData;
	import cgs.server.logging.actions.ClientAction;
	import cgs.server.logging.actions.IClientAction;

	public class BufferedMessage extends Message implements IQuestMessage
	{
		//Buffered actions.
		private var _actions:Array;
		
		//DQID retrieved from the server.
		private var _dqid:String;
		
		//Unique local id for the level.
		private var _localDQID:int;
		
		private var _questID:int;
		
		public function BufferedMessage(serverData:GameServerData = null)
		{
			super(serverData);
			
			_actions = [];
		}
		
		//
		// Dqid handling.
		//
		
		public function setDQID(value:String):void
		{
			_dqid = value;
		}
		
		public function get dqid():String
		{
			return _dqid;
		}
		
		public function isDQIDValid():Boolean
		{
			return _dqid != null;
		}
		
		public function setLocalDQID(value:int):void
		{
			_localDQID = value;
		}
		
		public function getLocalDQID():int
		{
			return _localDQID;
		}
		
		public function setQuestID(value:int):void
		{
			_questID = value;
		}
		
		public function getQuestID():int
		{
			return _questID;
		}
		
		//
		// Action buffer handling.
		//
		
		public function getActionCount():int
		{
			return _actions.length;
		}
		
		public function addAction(action:IClientAction):void
		{
			_actions.push(action.actionObject);
		}
		
		public function get actions():Array
		{
			return _actions;
		}
		
		//
		// Message object handling.
		//
		
		override public function injectParams():void
		{
			super.injectParams();
			
			injectLevelID(true);
			injectTypeID(true);
			injectSessionID(true);
			
			addProperty("actions", _actions);
			addProperty("dqid", _dqid);
			addProperty("qid", "" + _questID);
		}
	}
}