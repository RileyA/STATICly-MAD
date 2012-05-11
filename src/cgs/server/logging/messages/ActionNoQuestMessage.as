package cgs.server.logging.messages
{
	import cgs.server.logging.GameServerData;

	public class ActionNoQuestMessage extends Message
	{
		public function ActionNoQuestMessage(aid:int, details:Object = null, serverData:GameServerData = null)
		{
			super(serverData);
			
			addProperty("aid", aid);
			
			if(details != null)
			{
				setDetails(details);
			}
		}
		
		public function setDetails(value:Object):void
		{
			addProperty("a_detail", value);
		}
	}
}