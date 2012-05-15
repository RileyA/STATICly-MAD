package Surfaces
{
	import starling.display.Image;
	import flash.geom.Point;
	import starling.textures.Texture;
	import starling.display.Sprite;
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
		public static const BCARPET:String = "bcarpet";
		public static const RCARPET:String = "rcarpet";
		public static const GROUND:String = "ground";
		
		public static const DEPTH:Number = 0.1;
		
		private var q:Image;
		public static const scalar:Number=2;
		
		public function SurfaceElement(rectDef:b2BodyDef, offset:b2Vec2, w:Number, h:Number, userData:*, world:b2World, tex:Texture):void {
			var fd:b2FixtureDef = new b2FixtureDef();
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(w / 2, h / 2);
			fd.shape = ps;
			fd.isSensor = true;	
			fd.userData = userData;
			rectDef.position.Add(offset);
			m_physics = world.CreateBody(rectDef);
			m_physics.CreateFixture(fd);
			
			q = new Image(tex);
			q.width=w;
			q.height=h;
			q.x = -w / 2 + offset.x;
			q.y = -h / 2 + offset.y;
			
			q.setTexCoords(3,new Point(w*scalar,h*scalar));
			q.setTexCoords(1,new Point(w*scalar,0));
			q.setTexCoords(2,new Point(0,h*scalar));
			q.setTexCoords(0,new Point(0,0));
			addChild(q);
		}

		public function cleanup():void {
			m_physics.GetWorld().DestroyBody(m_physics);
			m_physics = null;
			while (numChildren > 0)
				removeChildAt(0);
		}
		
		public static function getRelatedType(type:String,rectDef:b2BodyDef,  offset:b2Vec2, w:Number, h:Number, 
												world:b2World):SurfaceElement {
			
			if (type == GROUND)
				return new Ground(rectDef, offset, w, h, world);
			else if (type == RCARPET)
				return new RedCarpet(rectDef, offset, w, h, world);
			else if (type == BCARPET)
				return new BlueCarpet(rectDef, offset, w, h, world);
			else
				return null;
			
		}
		
	}
	
}
