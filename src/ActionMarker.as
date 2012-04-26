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
		
		public function callAction(state:LevelState):void {
			action(state);
		}
		
		public function canAction(player:Player):Boolean {
			return chargeChecker(player);
		}
	}

}