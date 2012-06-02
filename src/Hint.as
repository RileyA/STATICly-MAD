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
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class Hint extends Sprite {

		[Embed(source = "../media/images/arrow.png")]
		private static const m_arrow:Class;
		private static const arrowTex:Texture=Texture.fromBitmap(new m_arrow);

		public var isText:Boolean = false;
		public var ppm:Number;
		public var info:HintInfo = null;
		public var im:Image;
		public var txt:TextField;

		public function Hint(x_:Number, y_:Number, 
			w:Number, h:Number, ang:Number, pxpm:Number,
			inf:HintInfo, text:String = null):void {
			info = inf;
			ppm = pxpm;
			x = x_ * pxpm;
			y = y_ * pxpm;
			rotation = ang * Math.PI / 180.0;

			makeImage(w,h);

			if (text) {
				isText = true;
				makeText(w,h,text);
			} 

			update();
		}

		public static function make(info:HintInfo, px:Number = 1.0):Hint {
			var h:Hint = new Hint(info.x, info.y, info.w, info.h, info.ang, 
				px, info, info.textHint ? info.text : null);
			return h;
		}

		public function update():void {
			if (isText) {
				if (im) im.visible = false;
				if (txt) txt.visible = true;
				if (!txt && info) {
					makeText(info.w, info.h, info.text);
				}
				txt.text = info ?  info.text.split(",").join("\n") : "";
			} else {
				if (im) im.visible = true;
				if (txt) txt.visible = false;
				if (!im) {
					makeImage(info.w, info.h);
				}
			}
		}

		public function makeText(w:Number,h:Number,text:String):void {
			txt = new TextField(w*ppm, 
				h*ppm, info ? "" : text,"akashi", 
				info ? info.textSize : 14, Colors.textColor);
			txt.hAlign = "center";
			txt.vAlign = "top";
			txt.x = -w/2*ppm;
			txt.y = -h/2*ppm;
			addChild(txt);
		}

		public function makeImage(w:Number,h:Number):void {
			im = new Image(arrowTex);
			im.width = w * ppm;
			im.height = h * ppm;
			im.x = -im.width/2;
			im.y = -im.height/2;
			addChild(im);
		}
	}
}
