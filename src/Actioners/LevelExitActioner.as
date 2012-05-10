package Actioners {
	
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.*;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.display.Quad;

	public class LevelExitActioner extends ActionerElement {

		public static const WIDTH:Number = 1.5;
		public static const HEIGHT:Number = -2.0;

		public function LevelExitActioner(rectDef:b2BodyDef, offset:b2Vec2, world:b2World):void {
			var center:b2Vec2 = new b2Vec2(offset.x, offset.y + HEIGHT/2);
			function cb(level:Level):void { level.markAsDone(); }
			function tr(player:Player):Boolean { return true; }
			super(rectDef, center, new ActionMarker(cb, tr, null, this), world);
		}

		override protected function getPolyShape():b2PolygonShape {
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(WIDTH/3, HEIGHT/3);
			return ps;
		}

		override protected function getSprite(x:Number, y:Number):DisplayObject {
			sprite = new Quad(WIDTH, HEIGHT, 0x990099);
			sprite.x = -WIDTH/2 + x;
			sprite.y = -HEIGHT/2 + y;
			//sprite.graphics.beginFill(0x990099);
			//sprite.graphics.drawRect(-WIDTH/2 + x, -HEIGHT/2 + y, WIDTH, HEIGHT);
			//sprite.graphics.endFill();
			return sprite;
		}
	}
}
