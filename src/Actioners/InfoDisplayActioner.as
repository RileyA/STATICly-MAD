package Actioners {
	
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.*;
	import flash.display.Bitmap;
	import starling.textures.*;
	import starling.display.*;
	import starling.core.*;
	import starling.text.TextField;
	import Colors;

	public class InfoDisplayActioner extends ActionerElement {

		public static const WIDTH:Number = 3.0;
		public static const HEIGHT:Number = 2.0;

		private var textSprite:TextField;
		private static const hideText:Boolean=false;

		public function InfoDisplayActioner(rectDef:b2BodyDef, offset:b2Vec2, world:b2World, extras:Array):void {		
			
			var center:b2Vec2 = new b2Vec2(offset.x, offset.y - HEIGHT/2);

			var textScale:Number=.04;
			var textSize:Number=16.0;
			var textWidth:Number=12*textSize;
			textSprite = new TextField(textWidth, 4.5*textSize, "0","Sans",textSize,Colors.textColor);
			textSprite.hAlign = "center";
			
			textSprite.x = -textWidth / 2 * textScale;
			
			textSprite.visible=!hideText;
			textSprite.scaleX = textScale;
			textSprite.scaleY = textSprite.scaleX;

			var i:int = 0;
			textSprite.text = extras[i];
			for(i=1; i<extras.length; i++) {
				textSprite.text += "\n"+extras[i];
			}
			
			function cb(level:Level):void {	return; }
			function tr(player:Player):Boolean { return false; }
			function startHint():void {
				textSprite.visible=true;
			}
			function endHint():void {
				textSprite.visible=!hideText;
			}
			super(rectDef, center, new ActionMarker(cb, tr, null, this, startHint, endHint), world);
		}

		override protected function getPolyShape():b2PolygonShape {
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(WIDTH/2, HEIGHT/2);
			return ps;
		}

		override protected function getSprite(x:Number, y:Number):DisplayObjectContainer {
			if(spriteContainer == null){
				spriteContainer = new Sprite();
				textSprite.y = -HEIGHT/2 + y - .1 - textSprite.height;
				spriteContainer.addChild(textSprite);
			}
			return spriteContainer;
		}
	}
}
