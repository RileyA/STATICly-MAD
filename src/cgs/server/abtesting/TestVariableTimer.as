package cgs.server.abtesting
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class TestVariableTimer
	{
		private var _timer:Timer;
		
		private var _timerDelay:int = 200;
		
		private var _varTimers:Dictionary;
		private var _timedVarCount:int;
		
		public function TestVariableTimer()
		{
			_varTimers = new Dictionary();
		}
		
		public function startVariableTimer(varName:String):void
		{
			var varTimer:VariableTimer = _varTimers[varName];
			if(varTimer == null)
			{
				varTimer = addVariableTimer(varName);
			}
			
			varTimer.start();
		}
		
		private function addVariableTimer(varName:String):VariableTimer
		{
			var varTimer:VariableTimer = new VariableTimer();
			_varTimers[varName] = varTimer;
			
			if(_timedVarCount == 0)
			{
				start();
			}
			_timedVarCount++;
			
			return varTimer;
		}
		
		private function removeVariableTimer(varName:String):VariableTimer
		{
			var varTimer:VariableTimer = _varTimers[varName];
			if(varTimer != null)
			{
				_timedVarCount--;
				delete _varTimers[varName];
				
				if(_timedVarCount == 0)
				{
					stop();
				}
			}
			
			return varTimer;
		}
		
		public function pauseVariableTimer(varName:String):void
		{
			var varTimer:VariableTimer = _varTimers[varName];
			if(varTimer != null)
			{
				varTimer.pause();
			}
		}
		
		public function containsVariableTimer(varName:String):Boolean
		{
			return _varTimers.hasOwnProperty(varName);
		}
		
		/**
		 * End a variable timer and returns the run time of the variable timer.
		 */
		public function endVariableTimer(varName:String):Number
		{
			var varTimer:VariableTimer = removeVariableTimer(varName);
			
			return varTimer != null ? varTimer.elapsedTime : 0;
		}
		
		//
		// Timer handling.
		//
		
		private function onTick(evt:TimerEvent):void
		{
			for each(var varTimer:VariableTimer in _varTimers)
			{
				varTimer.onTick(_timerDelay);
			}
		}
		
		public function start():void
		{
			if(_timer == null)
			{
				_timer = new Timer(_timerDelay);
				_timer.addEventListener(TimerEvent.TIMER, onTick);
			}
			
			_timer.start();
		}
		
		public function stop():void
		{
			if(_timer != null)
			{
				_timer.stop();
			}
		}
	}
}

internal class VariableTimer
{
	protected var _elapsedTime:int;
	
	protected var _running:Boolean;
	
	public function VariableTimer()
	{
		_elapsedTime = 0;
		_running = true;
	}
	
	public function onTick(delta:int):void
	{
		if(_running)
		{
			_elapsedTime += delta;
		}
	}
	
	public function pause():void
	{
		_running = false;
	}
	
	public function start():void
	{
		_running = true;
	}
	
	public function reset():void
	{
		_elapsedTime = 0;
		_running = true;
	}
	
	public function get elapsedTime():Number
	{
		return _elapsedTime / 1000;
	}
}