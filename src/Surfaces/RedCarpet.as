package Surfaces 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Surfaces.Ground;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class RedCarpet extends SurfaceElement 
	{
		
		public function RedCarpet(rectDef:b2BodyDef, w:Number, h:Number, world:b2World):void {
			super(rectDef, w, h, world);
		}
		
	}

}