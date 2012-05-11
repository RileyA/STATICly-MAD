package cgs.server.logging.messages
{
	import cgs.server.logging.GameServerData;

	public class CreateQuestRequest extends Message
	{
		public function CreateQuestRequest(name:String, typeID:int, serverData:GameServerData = null)
		{
			super(serverData);
			
			addProperty("q_name", name);
			addProperty("q_type_id", typeID);
		}
	}
}