package Surfaces
{
	import flash.display.Sprite;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import Surfaces.Ground;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class SurfaceElement extends GfxPhysObject {
		
		public static const DEPTH:Number = .1;
		
		private var sprite:Sprite;
		
		public function SurfaceElement(rectDef:b2BodyDef, w:Number, h:Number, world:b2World):void {
			var fd:b2FixtureDef = new b2FixtureDef();
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(w / 2, h / 2);
			fd.shape = ps;
			fd.isSensor = true;		
			fd.userData = this;
			
			m_physics = world.CreateBody(rectDef);
			//trace(m_physics.GetPosition().x, m_physics.GetPosition().y);
			m_physics.SetFixedRotation(false);
			m_physics.CreateFixture(fd);
			
			sprite = new Sprite();
			sprite.graphics.beginFill(0x666666);
			sprite.graphics.drawRect(
				0,
				0,
				w * PhysicsUtils.PIXELS_PER_METER,	
				h * PhysicsUtils.PIXELS_PER_METER
			);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		public static function getRelatedType(type:String, rectDef:b2BodyDef, w:Number, h:Number, 
												world:b2World):SurfaceElement {
			
			if (type == "ground")
				return new Ground(rectDef, w, h, world);
			else if (type == "red_carpet")
				return new RedCarpet(rectDef, w, h, world);
			else if (type == "blue_carpet")
				return new BlueCarpet(rectDef, w, h, world);
			else
				return null;
			
		}
		
	}
	
}
