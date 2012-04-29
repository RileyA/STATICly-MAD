package Chargable {
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import Box2D.Common.Math.b2Vec2;
	
	public class ChargableUtils {
		// Defines the numeric charge value for blue, red, or no charge.
		public static const CHARGE_BLUE:int = +1;
		public static const CHARGE_NONE:int = 0;
		public static const CHARGE_RED:int = -1;

		private static const COLOR_TRANS_BLUE:ColorTransform = new ColorTransform(.8,.8,1.0);
		private static const COLOR_TRANS_NONE:ColorTransform = new ColorTransform();
		private static const COLOR_TRANS_RED:ColorTransform = new ColorTransform(1.0,.8,.8);
		{
			COLOR_TRANS_RED.redOffset=150;
			COLOR_TRANS_BLUE.blueOffset=150;
		}

		public static function matchColorToPolarity(sprite:Sprite, polarity:int):void {
			switch (polarity) {
			case CHARGE_BLUE:
				sprite.transform.colorTransform = COLOR_TRANS_BLUE;
				break;
			case CHARGE_RED:
				sprite.transform.colorTransform = COLOR_TRANS_RED;
				break;
			default:
				sprite.transform.colorTransform = COLOR_TRANS_NONE;
				break;
			}
		}
		
		public static function makeCharges(strength:Number, x1:Number, y1:Number, x2:Number, y2:Number):Vector.<Charge>{
			var w:Number = (x2-x1);
			var h:Number = (y2-y1);
			const gridSize:Number=.3;
			var xCount:int=Math.max(1,Math.floor(w/gridSize));
			var yCount:int=Math.max(1,Math.floor(h/gridSize));
			var count:int=xCount*yCount;
			var cStren:Number=strength/count;
			var x:int;
			var y:int;
			var v:Vector.<Charge> = new Vector.<Charge>();
			var xStart:Number=((x1+x2)/2.0)-((xCount-1)/2.0*gridSize);
			var yStart:Number=((y1+y2)/2.0)-((yCount-1)/2.0*gridSize);
			for (x=0;x<xCount;x++){
				for (y=0;y<yCount;y++){
					v.push(new Charge(cStren,new b2Vec2(
								xStart+x*gridSize,
								yStart+y*gridSize
							)));
				}
			}
			return v;
		}
		
	}
}
