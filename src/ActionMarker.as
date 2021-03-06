package  
{
	/**
	 * ...
	 * @author Matthew Hall
	 */
	 
	import Box2D.Dynamics.*;
	import starling.display.Sprite;
	
	public class ActionMarker {
		
		private var callback:Function;
		private var canTrigger:Function;
		public var fixture:b2Fixture;
		public var sprite:Sprite;
		private var startHintFunc:Function;
		private var endHintFunc:Function;
		
		public function ActionMarker(callback:Function, canTrigger:Function, fix:b2Fixture, sprite:Sprite, startHintFunc:Function=null, endHintFunc:Function=null):void {
			this.callback = callback;
			this.canTrigger = canTrigger;
			fixture = fix;
			this.sprite = sprite;
			this.startHintFunc=startHintFunc;
			this.endHintFunc=endHintFunc;
		}
		
		public function callAction(level:Level):void {
			callback(level);
		}
		
		public function canAction(player:Player):Boolean {
			return canTrigger(player);
		}
		
		public function startHint():void {
			if (startHintFunc!=null) {
				startHintFunc();
			}
		}
		
		
		public function endHint():void {
			if (endHintFunc!=null) {
				endHintFunc();
			}
		}
	}

}
