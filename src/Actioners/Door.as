package Actioners 
{
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class Door extends ActionElement {
		
		public function Door(position:b2Vec2, world:b2World):void {
			super(postion, fromPixels(new b2Vec2(50, 100)), world);
		}
		
	}

}