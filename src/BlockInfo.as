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

		public function getCopy():BlockInfo {
			var out:BlockInfo = new BlockInfo;
			out.movement = movement;;
			for (var i:uint = 0; i < surfaces.length; ++i)
				out.surfaces.push(surfaces[i]);
			for (i = 0; i < actions.length; ++i)
				out.actions.push(actions[i]);
			for (i = 0; i < bounds.length; ++i)
				out.bounds.push(bounds[i].getCopy());
			out.position = position.getCopy();
			out.scale = scale.getCopy();
			out.insulated = insulated;
			out.strong = strong;
			out.chargePolarity = chargePolarity;
			return out;
		}
	}
}

