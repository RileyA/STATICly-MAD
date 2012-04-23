package Actioners
{
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ActionerElement extends GfxPhysObject{
		private var actionCallback:Function;
		
		/**
		*/
		public function ActionerElement(actionCallback:Function):void {
			super();
			this.actionCallback = actionCallback;
		}

		public function fireAction():void {
			actionCallback()
		}
	}
}
