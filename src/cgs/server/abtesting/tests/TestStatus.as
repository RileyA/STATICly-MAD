package cgs.server.abtesting.tests
{
	public class TestStatus
	{
		//Indicates if the test start message has been logged on the server.
		private var _started:Boolean;
		private var _startCount:int;
		
		//Indicates if the test complete message has been logged on the server.
		private var _completed:Boolean;
		private var _completeCount:int;
		
		//Current results id to be used for the test.
		private var _currResultID:int;
		
		private var _conditonStatus:ConditionTestStatus;
		
		public function TestStatus()
		{
			_conditonStatus = new ConditionTestStatus();
		}
		
		/**
		 * Get the next valid id for a test result.
		 */
		public function get nextResultID():int
		{
			return ++_currResultID;
		}
		
		public function get currentResultID():int
		{
			return _currResultID;
		}
		
		public function parseTestStatusData(dataObj:Object):void
		{
			_completeCount = dataObj.count;
			_completed = _completeCount > 0;
			_currResultID = dataObj.result_id;
		}
		
		public function parseVariableStatusData(dataObj:Object):void
		{
			_conditonStatus.parseVariableStatusData(dataObj);
		}
	}
}