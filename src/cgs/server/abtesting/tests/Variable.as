package cgs.server.abtesting.tests
{
	public class Variable
	{
		public static const BOOLEAN_VARIABLE:int = 0;
		public static const INTEGER_VARIABLE:int = 1;
		public static const NUMBER_VARIABLE:int = 2;
		public static const STRING_VARIABLE:int = 3;
		
		private var _id:int;
		
		//Condition that the variable belongs to.
		private var _condition:Condition;
		
		private var _name:String;
		
		private var _value:*;
		
		private var _type:int;
		
		//Indicates if the variable has been tested by the application.
		private var _tested:Boolean;
		
		//Indicates if testing was started on the variable.
		private var _testingStarted:Boolean;
		
		//Indicates if a test end can be logged.
		private var _inTest:Boolean;
		
		//Results of this variable being tested.
		private var _results:Object;
		
		public function Variable()
		{
		}
		
		public function get id():int
		{
			return _id;
		}
		
		/**
		 * Get the test that the variable belongs to.
		 */
		public function get abTest():ABTest
		{
			return _condition != null ? _condition.test : null;
		}
		
		/**
		 * Get the name of the variable.
		 * @return String the name of the variable.
		 */
		public function get name():String
		{
			return _name;
		}
		
		public function set results(value:Object):void
		{
			_results = value;
		}
		
		public function get results():Object
		{
			return _results;
		}
		
		public function get hasResults():Boolean
		{
			return _results != null;
		}
		
		//
		// Local testing variables. Keeps end results from being sent when the variable is not in test.
		//
		
		public function set inTest(value:Boolean):void
		{
			_inTest = value;
		}
		
		public function get inTest():Boolean
		{
			return _inTest;
		}
		
		/**
		 * Set that overall testing has started for the variable.
		 */
		public function set testingStarted(value:Boolean):void
		{
			_testingStarted = value;
		}
		
		public function get testingStarted():Boolean
		{
			return _testingStarted;
		}
		
		/**
		 * Set that the first
		 */
		public function set tested(value:Boolean):void
		{
			_tested = value;
		}
		
		public function get tested():Boolean
		{
			return _tested;
		}
		
		public function set condition(cond:Condition):void
		{
			_condition = cond;
		}
		
		public function get value():*
		{
			return _value;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function parseJSONData(dataObj:Object):void
		{
			_id = dataObj.id;
			_name = dataObj.v_key;
			_type = dataObj.v_type;
			
			if(_type == BOOLEAN_VARIABLE)
			{
				_value = convertToBoolean(dataObj.v_value);
			}
			else
			{
				_value = dataObj.v_value;
			}
		}
		
		private function convertToBoolean(text:String):Boolean
		{
			var normalizedText:String = text.toLowerCase();
			return normalizedText == "true" || normalizedText == "1";
		}
	}
}