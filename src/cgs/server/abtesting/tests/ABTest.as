package cgs.server.abtesting.tests
{
	public class ABTest
	{
		//Unique id of the test.
		private var _id:int;
		
		//Overrides the cid of the game if user is placed in the test.
		private var _cid:int;
		
		//Indicates if multiple results can be logged for the test.
		private var _multiResults:Boolean;
		
		//Condition for this test.
		private var _condition:Condition;
		
		private var _testStatus:TestStatus;
		
		private var _completeCount:int;
		
		public function ABTest()
		{
			_testStatus = new TestStatus();
		}
		
		public function get id():int
		{
			return _id;
		}
		
		/**
		 * Indicates if the test has a CID set for the user.
		 */
		public function get hasCID():Boolean
		{
			return _cid >= 0;
		}
		
		/**
		 * Get the logging cid for the user.
		 */
		public function get cid():int
		{
			return _cid;
		}
		
		public function get nextResultID():int
		{
			return _testStatus.nextResultID;
		}
		
		public function get currentResultID():int
		{
			return _testStatus.currentResultID;
		}
		
		public function get conditionID():int
		{
			return _condition.id;
		}
		
		public function get variables():Vector.<Variable>
		{
			return _condition.variables;
		}
		
		/**
		 * Indicates if testing has started on any of the variables in the test.
		 */
		public function get hasTestingStarted():Boolean
		{
			return _condition.hasTestingStarted;
		}
		
		/**
		 * Reset the test. To be run again.
		 */
		public function reset():void
		{
			_completeCount++;
			
			_condition.reset();
		}
		
		/**
		 * Indicates if this test has been fully tested on the client. 
		 */
		public function get tested():Boolean
		{
			return _condition.tested;
		}
		
		public function parseTestStatusData(dataObj:Object):void
		{
			_testStatus.parseTestStatusData(dataObj);
		}
		
		public function parseVariableStatus(dataObj:Object):void
		{
			_testStatus.parseVariableStatusData(dataObj);
		}
		
		public function parseJSONData(dataObj:Object):void
		{
			_id = dataObj.test_id;
			_multiResults = dataObj.multi_results;
			
			_condition = new Condition();
			_condition.parseJSONData(dataObj.cond);
			_condition.test = this;
			
			_cid = dataObj.cid;
		}
	}
}