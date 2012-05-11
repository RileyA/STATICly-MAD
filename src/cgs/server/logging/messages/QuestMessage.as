package cgs.server.logging.messages
{
	import cgs.server.logging.GameServerData;

    public dynamic class QuestMessage extends Message implements IQuestMessage
    {
        private var _questID:String;
        
        private var _dynamicQuestID:String;
        
		//Details logged at the start of a quest.
        private var _questDetail:Object;
		
        public function QuestMessage(questID:int, details:Object, questStart:Boolean, aeSeqID:String = null, dqid:String = null, serverData:GameServerData = null)
		{
			super(serverData);
			
            setQuestID(questID);
			
			_questDetail = details;
			addProperty("q_detail", _questDetail);
			
			addProperty("q_s_id", questStart ? 1 : 0);
			
			//Only add the ae sequence id if it is valid.
			if(aeSeqID != null)
			{
				addProperty("ae_seq_id", aeSeqID);
			}
			if(dqid != null)
			{
				setDQID(dqid);
			}
        }
		
		public function setQuestID(value:int):void
		{
			_questID = "" + value;
			addProperty("qid", _questID);
		}
		
		public function getQuestID():int
		{
			return _messageObject.qid;
		}
        
        public function setDQID(value:String):void
        {
            _dynamicQuestID = value;
			addProperty("dqid", dqid);
        }
		
        public function get dqid():String
        {
            return _dynamicQuestID;
        }
		
		public function get isDQIDValid():Boolean
		{
			return _dynamicQuestID != null;
		}
        
        public function get qid():String
        {
            return _questID;
        }
        
        public function get q_detail():Object
        {
            return _questDetail;
        }
		
		override public function injectParams():void
		{
			super.injectParams();
			
			injectLevelID(true);
			injectTypeID(true);
			injectSessionID(false);
		}
    }
}