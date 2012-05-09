package Actioners {
	import flash.display.Sprite;
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import Colors;
	
	public class LevelEntranceActioner extends ActionerElement {

		public static const WIDTH:Number = 1.0;
		public static const HEIGHT:Number = -1.4;
		private var textSprite:TextField;

		public function LevelEntranceActioner(rectDef:b2BodyDef, offset:b2Vec2, world:b2World, levelName:String):void {
			var center:b2Vec2 = new b2Vec2(offset.x, offset.y + HEIGHT/2);
			
			
			var format:TextFormat = new TextFormat("Sans", 1, Colors.textColor);
			format.align = TextFormatAlign.CENTER;
			textSprite = new TextField();
			
			var textWidth:Number=WIDTH*16;
			var textScale:Number=.5;
			textSprite.width = textWidth;
			textSprite.height = 10;
			textSprite.x = -textWidth/2*textScale;
			textSprite.y = -3.5;
			textSprite.defaultTextFormat = format;
			textSprite.text = levelName;
			textSprite.selectable = false;
			textSprite.visible=false;
			textSprite.scaleX=textScale;
			textSprite.scaleY=textSprite.scaleX;
			
			function cb(level:Level):void { level.markAsDone(levelName); }
			function tr(player:Player):Boolean { return true; }
			function startHint():void {
				textSprite.visible=true;
			}
			function endHint():void {
				textSprite.visible=false;
			}
			super(rectDef, center, new ActionMarker(cb, tr, null, this, startHint, endHint), world);
		}

		override protected function getPolyShape():b2PolygonShape {
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(WIDTH/3, HEIGHT/3);
			return ps;
		}

		override protected function getSprite(x:Number, y:Number):Sprite {
			sprite = new Sprite();
			sprite.graphics.beginFill(0xff6600);
			sprite.graphics.drawRect(-WIDTH/2 + x, -HEIGHT/2 + y, WIDTH, HEIGHT);
			sprite.graphics.endFill();
			

			sprite.addChild(textSprite)
			return sprite;
		}
	}
}
