package  
{
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ActionMarker {
		
		private var callback:Function;
		private var canTrigger:Function;
		
		public function ActionMarker(callback:Function, canTrigger:Function):void {
			this.callback = callback;
			this.canTrigger = canTrigger;
		}
		
		public function callAction(level:Level):void {
			callback(level);
		}
		
		public function canAction(player:Player):Boolean {
			return canTrigger(player);
		}
	}

}
