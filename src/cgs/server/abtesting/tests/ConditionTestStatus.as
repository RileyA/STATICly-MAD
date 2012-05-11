package cgs.server.abtesting.tests
{
	import flash.utils.Dictionary;

	public class ConditionTestStatus
	{
		private var _condID:int;
		
		//Test status of each variable in the test.
		private var _variables:Vector.<VariableTestStatus>;
		
		public function ConditionTestStatus()
		{
			_variables = new Vector.<VariableTestStatus>();
		}
		
		private function getVariableStatus(id:int):VariableTestStatus
		{
			for each(var variable:VariableTestStatus in _variables)
			{
				if(variable.id == id)
				{
					return variable;
				}
			}
			
			return null;
		}
		
		public function parseVariableStatusData(dataObj:Object):void
		{
			var varID:int = dataObj.var_id;
			var variable:VariableTestStatus = getVariableStatus(varID);
			if(variable == null)
			{
				variable = new VariableTestStatus(varID);
				_variables.push(variable);
			}
			
			variable.parseVariableStatusData(dataObj);
		}
	}
}