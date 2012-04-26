package Surfaces
{
	import flash.display.Sprite;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import Block;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class SurfaceElement extends GfxPhysObject {
		
		public static const DEPTH:Number = 0.1;
		
		private var sprite:Sprite;
		
		public function SurfaceElement(rectDef:b2BodyDef, offset:b2Vec2, w:Number, h:Number, action:ActionMarker, world:b2World):void {
			var fd:b2FixtureDef = new b2FixtureDef();
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(w / 2, h / 2);
			fd.shape = ps;
			fd.isSensor = true;		
			fd.userData = this;
			rectDef.position.Add(offset);
			m_physics = world.CreateBody(rectDef);
			m_physics.CreateFixture(fd);

			addChild(drawSprite);
		}

		private function drawSprite():Sprite {
			sprite = new Sprite();

			sprite.graphics.beginFill(0x7CFC00);
			sprite.graphics.drawRect(-w/2 + offset.x, -h/2 + offset.y, w, h);
			sprite.graphics.endFill();
		}
		
		public static function getRelatedType(type:String,rectDef:b2BodyDef,  offset:b2Vec2, w:Number, h:Number, 
												world:b2World):SurfaceElement {
			
			if (type == Block.GROUND)
				return new Ground(rectDef, offset, w, h, world);
			else if (type == Block.RCARPET)
				return new RedCarpet(rectDef, offset, w, h, world);
			else if (type == Block.BCARPET)
				return new BlueCarpet(rectDef, offset, w, h, world);
			else
				return null;
			
		}
		
	}
	
}
