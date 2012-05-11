package cgs.server.abtesting.tests
{
	public class Condition
	{
		//Test that the condition belongs to.
		private var _test:ABTest;
		
		//Id of the condition.
		private var _id:int;
		
		//Variables contained in the condition.
		private var _variables:Vector.<Variable>;
		
		public function Condition()
		{
			
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get variables():Vector.<Variable>
		{
			return _variables != null ? _variables.concat() : null;
		}
		
		/**
		 * Indicates if testing has started on any variables in the condition.
		 */
		public function get hasTestingStarted():Boolean
		{
			for each(var variable:Variable in _variables)
			{
				if(variable.testingStarted)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Reset the test condition to be run again.
		 */
		public function reset():void
		{
			for each(var variable:Variable in _variables)
			{
				variable.tested = false;
			}
		}
		
		/**
		 * Indicates if all variables in the condition have been tested by the application.
		 */
		public function get tested():Boolean
		{
			for each(var variable:Variable in _variables)
			{
				if(!variable.tested)
				{
					return false;
				}
			}
			
			return true;
		}
		
		public function set test(abtest:ABTest):void
		{
			_test = abtest;
		}
		
		public function get test():ABTest
		{
			return _test;
		}
		
		public function parseJSONData(dataObj:Object):void
		{
			_id = dataObj.cond_id;
			
			_variables = new Vector.<Variable>();
			var variable:Variable;
			var vars:Array = dataObj.vars;
			for each(var varObj:Object in vars)
			{
				variable = new Variable();
				variable.parseJSONData(varObj);
				variable.condition = this;
				_variables.push(variable);
			}
		}
	}
}