package  
{
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ActionMarker {
		
		private var action:Function;
		private var chargeChecker:Function;
		
		public function ActionMarker(action:Function, chargeChecker:Function):void {
			this.action = action;
			this.chargeChecker = chargeChecker;
		}
		
		public function callAction(level:Level):void {
			action(level);
		}
		
		public function canAction(player:Player):Boolean {
			return chargeChecker(player);
		}
	}

}
