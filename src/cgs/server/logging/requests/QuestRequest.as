package cgs.server.logging.requests
{
	import cgs.server.logging.messages.IQuestMessage;

	public class QuestRequest extends CallbackRequest
	{
		private var _questMessage:IQuestMessage;
		
		private var _questGameID:int = 0;
		
		//Function which should be called when the request can be sent to the server.
		private var _requestCallback:Function;
		
		public function QuestRequest(callback:Function, questMessage:IQuestMessage, requestCallback:Function, questGameID:int = 0)
		{
			super(callback);
			
			_questMessage = questMessage;
			_requestCallback = requestCallback;
			_questGameID = questGameID;
		}
		
		public function get requestCallback():Function
		{
			return _requestCallback;
		}
		
		public function setDQID(value:String):void
		{
			if(_questMessage != null)
			{
				_questMessage.setDQID(value);
			}
		}
		
		public function getDQID():String
		{
			return _questMessage != null ? _questMessage.dqid : null;
		}
		
		public function get questMessage():IQuestMessage
		{
			return _questMessage;
		}
		
		public function get questMessageObject():Object
		{
			_questMessage.injectParams();
			if(_questGameID > 0)
			{
				_questMessage.addProperty("g_s_id", _questGameID);
			}
			
			return _questMessage.messageObject;
		}
	}
}