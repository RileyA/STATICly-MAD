package Chargable {
	import starling.display.Quad;
	import Box2D.Common.Math.b2Vec2;
	
	public class ChargableUtils {
		// Defines the numeric charge value for blue, red, or no charge.
		public static const CHARGE_BLUE:int = +1;
		public static const CHARGE_NONE:int = 0;
		public static const CHARGE_RED:int = -1;
		
		public static function makeCharges(strength:Number, x1:Number, y1:Number, x2:Number, y2:Number):Vector.<Charge>{
			var w:Number = (x2-x1);
			var h:Number = (y2-y1);
			const gridSize:Number=.8;
			var xCount:int=Math.max(1,Math.floor(w/gridSize));
			var yCount:int=Math.max(1,Math.floor(h/gridSize));
			xCount=Math.min(xCount,6);
			yCount=Math.min(yCount,6);
			var count:int=xCount*yCount;
			var cStren:Number=strength/count;
			var x:int;
			var y:int;
			var xSpacing:Number=w/(xCount+1.0);
			var ySpacing:Number=h/(yCount+1.0);
			var v:Vector.<Charge> = new Vector.<Charge>();
			for (x=0;x<xCount;x++){
				for (y=0;y<yCount;y++){
					v.push(new Charge(cStren,new b2Vec2(
								x1+(x+1)*xSpacing,
								y1+(y+1)*ySpacing
							)));
				}
			}
			return v;
		}
		
	}
}
