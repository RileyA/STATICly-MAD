package Surfaces 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class Ground extends SurfaceElement {
		
		public function Ground(position:b2Vec2, w:Number, h:Number, world:b2World):void {
			super(position, w, h, world);
		}
		
	}

}