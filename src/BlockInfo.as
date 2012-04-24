package 
{
	import flash.utils.*;
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class BlockInfo {

		/** Constructor, just sets defaults */
		public function BlockInfo():void {
			width = 10;
			height = 10;
			x = 0;
			y = 0;
			movement = "fixed";
			pixels = false;
		}

		// TODO: define a way of setting shapes other than rectangles in 
		// a nice clean JSON-able manner
		public var width:Number;
		public var height:Number;
		public var x:Number;
		public var y:Number;
		public var movement:String = "";
		public var pixels:Boolean;
		public var surfaces:Vector.<String> = new Vector.<String>();
		public var actions:Vector.<String> = new Vector.<String>();
	}
	
}
