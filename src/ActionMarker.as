package  
{
	/**
	 * ...
	 * @author Matthew Hall
	 */
	 
	import Box2D.Dynamics.*;
	import flash.display.Sprite;
	
	public class ActionMarker {
		
		private var callback:Function;
		private var canTrigger:Function;
		public var fixture:b2Fixture;
		public var sprite:Sprite;
		
		public function ActionMarker(callback:Function, canTrigger:Function, fix:b2Fixture, sprite:Sprite):void {
			this.callback = callback;
			this.canTrigger = canTrigger;
			fixture = fix;
			this.sprite = sprite;
		
		}
		
		public function callAction(level:Level):void {
			callback(level);
		}
		
		public function canAction(player:Player):Boolean {
			return canTrigger(player);
		}
	}

}
