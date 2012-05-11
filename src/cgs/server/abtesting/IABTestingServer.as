package cgs.server.abtesting
{
	public interface IABTestingServer
	{
		function requestUserTestConditions(callback:Function = null):void;
		
		function noUserConditions():void;
		
		function logTestStart(testID:int, conditionID:int, detail:Object = null, callback:Function = null):void;
		
		function logTestEnd(testID:int, conditionID:int, detail:Object = null, callback:Function = null):void;
		
		function logConditionVariableStart(testID:int, conditionID:int,
				varID:int, resultID:int, time:Number = -1, detail:Object = null, callback:Function = null):void;
		
		function logConditionVariableResults(testID:int, conditionID:int,
				variableID:int, resultID:int, time:Number = -1, detail:Object = null, callback:Function = null):void;
	}
}