package 
{
	import flash.utils.*;
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class BlockInfo {
		// TODO: define a way of setting shapes other than rectangles in 
		// a nice clean JSON-able manner
		public var movement:String = "fixed";
		public var surfaces:Vector.<String> = new Vector.<String>();
		public var actions:Vector.<String> = new Vector.<String>();
		public var bounds:Vector.<UVec2> = new Vector.<UVec2>();
		public var position:UVec2 = new UVec2;
		public var scale:UVec2 = new UVec2;
		
		public var insulated:Boolean = true;
		public var chargePolarity:int = 0;
		public var strong:Boolean = true;
	}
	
}
