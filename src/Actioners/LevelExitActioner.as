package Actioners {
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.*;

	public class LevelExitActioner extends ActionerElement {

		public function LevelExitActioner(rectDef:b2BodyDef, offset:b2Vec2, am:ActionMarker, world:b2World):void {
			super(rectDef, offset, am, world);
		}

		override protected function getPolyShape():b2PolygonShape {
			return super.getPolyShape();
		}
	}
}
