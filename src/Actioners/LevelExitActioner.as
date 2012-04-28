package Actioners {
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;

	public class LevelExitActioner extends ActionerElement {

		public function LevelExitActioner(rectDef:b2BodyDef, offset:b2Vec2, w:Number, h:Number, am:ActionMarker, world:b2World):void {
			super(rectDef, offset, w, h, am, world);
		}
	}
}
