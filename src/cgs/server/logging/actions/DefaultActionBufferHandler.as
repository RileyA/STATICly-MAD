package cgs.server.logging.actions
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class DefaultActionBufferHandler implements IActionBufferHandler
	{
		private var _timer:Timer;
		
		private var _listener:IActionBufferListener;
		
		private var _elapsedTime:Number;
		
		//Time used at the start of the buffer handler for a level.
		private var _minTime:Number;
		
		//Time used to send actions after the ramp time has elapsed.
		private var _maxTime:Number;
		
		//Time it takes to change from the min time for sending actions to the max time.
		private var _rampTime:Number;
		
		public function DefaultActionBufferHandler()
		{
			_elapsedTime = 0;
		}
		
		/**
		 * Set the timing properties for the action buffer handler.
		 * 
		 * @param startBufferTime time (ms) it takes for actions to be flushed at start of quest.
		 * @param endBufferTime time (ms) it takes for actions to be flushed at end of ramp time.
		 * @param rampTime time (ms) it takes to change from start buffer time to end time.
		 */
		public function setProperties(startBufferTime:Number, endBufferTime:Number, rampTime:Number):void
		{
			_minTime = startBufferTime;
			_maxTime = endBufferTime;
			_rampTime = rampTime;
		}
		
		//Handle flushing actions and reseting the timer to flush actions again.
		private function handleTimer(evt:TimerEvent):void
		{
			if(_listener != null)
			{
				_listener.flushActions();
			}
			
			if(_elapsedTime < _rampTime)
			{
				_elapsedTime += _timer.delay;
				if(_elapsedTime > _rampTime)
				{
					_elapsedTime = _rampTime;
				}
			}
			_timer.reset();
			_timer.delay = getNextFlushTime();
			//trace("Starting new buffer flush timer with time: " + _timer.delay + " (ms)");
			_timer.start();
		}
		
		//Get the time it should take for the next flush of user actions.
		private function getNextFlushTime():Number
		{
			if(_rampTime == 0) return _maxTime;
			
			return ((_elapsedTime / _rampTime) * (_maxTime - _minTime)) + _minTime;
		}
		
		//
		// Interface methods.
		//
		
		/**
		 * @inheritDoc
		 */
		public function set listener(value:IActionBufferListener):void
		{
			_listener = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function start():void
		{
			if(_timer == null)
			{
				_timer = new Timer(getNextFlushTime(), 1);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimer);
			}
			
			//trace("Starting buffer flush timer with time: " + _timer.delay + " (ms)");
			_timer.start();
		}
		
		/**
		 * @inheritDoc
		 */
		public function stop():void
		{
			if(_timer != null)
			{
				_timer.stop();
				//trace("Buffer flush handler has been stopped.");
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function reset():void
		{
			_elapsedTime = 0;
			if(_timer != null)
			{
				_timer.reset();
				_timer.delay = getNextFlushTime();
			}
		}
		
		//Not used.
		public function onTick(delta:Number):void {	}
	}
}