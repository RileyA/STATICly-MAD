package cgs.server.abtesting.messages
{
	import cgs.server.logging.GameServerData;
	import cgs.server.logging.messages.Message;
	
	import com.adobe.serialization.json.JSONEncoder;
	
	public class TestStatusMessage extends Message
	{
		public function TestStatusMessage(testID:int, conditionID:int, start:Boolean = true, detail:Object = null, serverData:GameServerData = null)
		{
			super(serverData);
			
			addProperty("test_id", testID);
			addProperty("cond_id", conditionID);
			addProperty("start", start ? 1 : 0);
			
			if(detail != null)
			{
				var encode:JSONEncoder = new JSONEncoder(detail);
				addProperty("detail", encode.getString());
			}
		}
	}
}