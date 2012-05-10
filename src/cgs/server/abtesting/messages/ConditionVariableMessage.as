package cgs.server.abtesting.messages
{
	import cgs.server.logging.GameServerData;
	import cgs.server.logging.messages.Message;
	
	import com.adobe.serialization.json.JSONEncoder;
	
	public class ConditionVariableMessage extends Message
	{
		public function ConditionVariableMessage(testID:int, conditionID:int, varID:int,
				resultID:int, start:Boolean = false, time:Number = -1, detail:Object = null, serverData:GameServerData = null)
		{
			super(serverData);
			
			addProperty("test_id", testID);
			addProperty("cond_id", conditionID);
			addProperty("var_id", varID);
			addProperty("start", start ? 1 : 0);
			addProperty("result_id", resultID);
			
			if(time >= 0)
			{
				addProperty("time", time);
			}
			
			if(detail != null)
			{
				var encode:JSONEncoder = new JSONEncoder(detail);
				addProperty("detail", encode.getString());
			}
		}
	}
}