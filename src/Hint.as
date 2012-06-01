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

		[Embed(source = "../media/images/Rivet.png")]
		private static const m_rivet:Class;
		private static const rivetTex:Texture=Texture.fromBitmap(new m_rivet);

		public var isText:Boolean = false;
		public var ppm:Number;

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
				var im:Image = new Image(rivetTex);
				im.width = w * pxpm;
				im.height = h * pxpm;
				im.x = -im.width/2;
				im.y = -im.width/2;
				addChild(im);
			}
		}
	}
}
