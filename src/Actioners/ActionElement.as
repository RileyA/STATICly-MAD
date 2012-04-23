package Actioners
{
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ActionElement extends GfxPhysObject{
		
		public function SurfaceElement(position:b2Vec2, world:b2World):void {
			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(w / 2, h / 2);
			fd.shape = ps;
			fd.isSensor = true;
			rectDef.position = position;
			rectDef.angle = 0.0;
			
			fd.userData = this;
			
			m_physics = world.CreateBody(rectDef);
			m_physics.CreateFixture(fd);
		}
		
	}
	
}
