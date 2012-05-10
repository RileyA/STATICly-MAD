package cgs.server.logging.actions
{
    /**
     * Action performed by the user to be sent to the server to be logged.
     */
	//TODO - Rewrite to mirror the message model. Don't want to send empty or null properties to the server.
    public class ClientAction implements IClientAction
    {
		protected var _isBufferable:Boolean = true;
		
        protected var _aid:int;
        
        //Starting time stamp for the event.
        protected var _startTick:uint;
		protected var _endTick:uint;
		
		protected var _statusID:uint;
		
		private var _detailObject:Object;
		
		//Object used to send action properties to the server.
		private var _actionObject:Object;
        
		/**
		 * Create a new client action to be logged on the server.
		 * 
		 * @param actionID the id of the action as defined by the application.
		 * @param startTimeStamp the starting time of the action.
		 * @param endTimeStamp the ending time of the action.
		 * @param statusID optional id to be included with the action.
		 */
        public function ClientAction(actionID:int = 0, startTimeStamp:int = 0, endTimeStamp:int = 0, statusID:int = 0)
        {
            _aid = actionID;
			
            _startTick = startTimeStamp;
            _endTick = endTimeStamp;
			
			_statusID = statusID;
			
			_actionObject = {};
			
			//Add the required properties.
			setActionID(actionID);
			setStartTimeStamp(startTimeStamp);
			setEndTimeStamp(endTimeStamp);
			setStatusID(statusID);
			
			/*if(endTimeStamp >= 0)
			{
				setEndTimeStamp(endTimeStamp);
			}
			if(statusID >= 0)
			{
				setStatusID(statusID);
			}*/
        }
		
		/**
		 * Add a property to the action which will be sent to the server.
		 */
		public function addProperty(key:String, value:*):void
		{
			_actionObject[key] = value;
		}
		
		/**
		 * Add a property to the details field of the action message.
		 */
		public function addDetailProperty(key:String, value:*):void
		{
			if(_detailObject == null)
			{
				_detailObject = {};
				addProperty("detail", _detailObject);
			}
			
			_detailObject[key] = value;
		}
		
		public function get detailObject():Object
		{
			return _detailObject;
		}
		
		/**
		 * Indicates if this action is bufferable, this is true by default.
		 * Can be changed by calling setBufferable.
		 */
		public function isBufferable():Boolean
		{
			return _isBufferable;
		}
		
		public function setBufferable(value:Boolean):void
		{
			_isBufferable = value;
		}
		
		/**
		 * Set the detail properties for the action. Only dynamic properties of
		 * the passed object will be added to the detail field of the message.
		 * 
		 * @param value instance of the Object class which has detail properties to be logged.
		 */
		public function setDetail(value:Object):void
		{
			if(value != null)
			{
				for(var key:String in value)
				{
					addDetailProperty(key, value[key]);
				}
			}
		}
		
		/**
		 * Set the action id for this action.
		 */
		public function setActionID(value:int):void
		{
			addProperty("aid", value);
		}
		
		/**
		 * Set the starting time stamp for this action.
		 */
		public function setStartTimeStamp(value:int):void
		{
			addProperty("ts", value);
		}
		
		/**
		 * Set the ending time stamp for this action. This paramter is optional.
		 */
		public function setEndTimeStamp(value:int):void
		{
			addProperty("te", value);
		}
		
		/**
		 * Set the status id for this action. This paramter is optional.
		 */
		public function setStatusID(value:int):void
		{
			addProperty("stid", value);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get actionObject():Object
		{
			return _actionObject;
		}
    }
}