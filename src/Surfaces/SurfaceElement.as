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
	public class SurfaceElement extends GfxPhysObject {
		
		public function SurfaceElement(position:b2Vec2, w:Number, h:Number, world:b2World):void {
			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(w / 2, h / 2);
			fd.shape = ps;
			fd.isSensor = true;
			rectDef.position = position;
			rectDef.angle = 0.0;
			
			m_physics = world.CreateBody(rextDef);
			m_physics.CreateFixture(fd);
		}
		
		public static function getRelatedType(type:String, position:b2Vec2, w:Number, h:Number, 
												world:b2World):SurfaceElement {
			if (type == "ground")
				return new Ground(position, w, h, world);
			else
				return null;
			
		}
		
	}
	
}