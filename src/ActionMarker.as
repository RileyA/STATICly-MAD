package  
{
	/**
	 * ...
	 * @author Matthew Hall
	 */
	 
	import Box2D.Dynamics.*;
	
	public class ActionMarker {
		
		private var callback:Function;
		private var canTrigger:Function;
		public var fixture:b2Fixture;
		
		public function ActionMarker(callback:Function, canTrigger:Function, fix:b2Fixture):void {
			this.callback = callback;
			this.canTrigger = canTrigger;
			fixture=fix;
		}
		
		public function callAction(level:Level):void {
			callback(level);
		}
		
		public function canAction(player:Player):Boolean {
			return canTrigger(player);
		}
	}

}
