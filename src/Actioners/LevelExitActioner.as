package Actioners {

	public class LevelExitActioner extends ActionerElement {

		public function LevelExitActioner(position:b2Vec2, am:ActionMarker, world:b2World):void {
			super(postion, fromPixels(new b2Vec2(50, 100)), am, world);
		}
	}
}
