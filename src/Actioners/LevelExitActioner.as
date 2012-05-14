package Actioners {
	
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.*;
	import flash.display.Bitmap;
	import starling.textures.*;
	import starling.display.*;
	import starling.core.*;

	public class LevelExitActioner extends ActionerElement {

		public static const WIDTH:Number = 1.5;
		public static const HEIGHT:Number = -2.0;

		[Embed(source = "../../media/images/DoorExit.png")]
		private static const DoorExit:Class;

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

		override protected function getSprite(x:Number, y:Number):DisplayObjectContainer {
			if(spriteContainer == null){
				spriteContainer = new Sprite();
				var deImage:Image = new Image(Texture.fromBitmap(new DoorExit()));
				deImage.x = -WIDTH/2 + x;
				deImage.y = -HEIGHT / 2 + y;
				deImage.height = HEIGHT;
				deImage.width = WIDTH;
				spriteContainer.addChild(deImage);
			}
			return spriteContainer;
		}
	}
}
