package cgs.server.abtesting.tests
{
	public class VariableTestStatus
	{
		private var _id:int;
		
		private var _started:Boolean;
		private var _startCount:int;
		
		private var _completed:Boolean;
		private var _completeCount:int;
		
		public function VariableTestStatus(id:int)
		{
			_id = id;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function parseVariableStatusData(dataObj:Object):void
		{
			if(dataObj.hasOwnProperty("start"))
			{
				var start:Boolean = dataObj.start == "1";
				var count:int = dataObj.v_count;
				
				if(start)
				{
					_started = true;
					_startCount = count;
				}
				else
				{
					_completed = true;
					_completeCount = count;
				}
			}
		}
	}
}