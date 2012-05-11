package cgs.server.logging.messages
{
	import cgs.server.logging.GameServerData;

	public class ScoreMessage extends Message implements IQuestMessage
	{
		private var _dqid:String;
		
		public function ScoreMessage(score:int, serverData:GameServerData = null)
		{
			super(serverData);
			
			addProperty("score", score);
		}
		
		//
		// Message property injection.
		//
		
		override public function injectParams():void
		{
			super.injectParams();
			
			injectUserName();
		}
		
		//
		// QuestMessage interface methods.
		//
		
		/**
		 * Set the quest id for the score message.
		 */
		public function setQuestID(value:int):void
		{
			addProperty("qid", value);
		}
		
		public function getQuestID():int
		{
			return _messageObject.qid;
		}
		
		/**
		 * Sets the dynamic quest id for the quest message.
		 */
		public function setDQID(value:String):void
		{
			_dqid = value;
			addProperty("dqid", value);
		}
		
		public function get dqid():String
		{
			return _dqid;
		}
	}
}