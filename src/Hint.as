package {

	import Box2D.Dynamics.Joints.*;
	import starling.display.*;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import Surfaces.*;
	import Actioners.*;
	import Chargable.*;
	import starling.utils.Color;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import starling.textures.Texture;
	
	public class Hint extends Sprite {

		[Embed(source = "../media/images/arrow.png")]
		private static const m_arrow:Class;
		private static const arrowTex:Texture=Texture.fromBitmap(new m_arrow);

		public var isText:Boolean = false;
		public var ppm:Number;
		public var info:HintInfo = null;
		public var im:Image;

		public function Hint(x_:Number, y_:Number, 
			w:Number, h:Number, ang:Number, pxpm:Number,
			text:String = null):void {
			ppm = pxpm;
			x = x_ * pxpm;
			y = y_ * pxpm;
			rotation = ang * Math.PI / 180.0;

			if (text) {
				isText = true;
			} else {
				im = new Image(arrowTex);
				im.width = w * pxpm;
				im.height = h * pxpm;
				im.x = -im.width/2;
				im.y = -im.width/2;
				addChild(im);
			}
		}

		public static function make(info:HintInfo, px:Number = 1.0):Hint {
			var h:Hint = new Hint(info.x, info.y, info.w, info.w, info.ang, px,
				info.textHint ? info.text : null);
			h.info = info;
			return h;
		}
	}
}
