package {
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import flash.display.Sprite;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import Surfaces.*;
	import Actioners.*;

	public class Block extends GfxPhysObject{
		
		public static const FREE:String = "free";
		public static const TRACKED:String = "tracked";
		public static const FIXED:String = "fixed";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const BCARPET:String = "bcarpet";
		public static const RCARPET:String = "rcarpet";
		public static const GROUND:String = "ground";
		
		private var movement:String;
		private var bodyWidth:Number;
		private var bodyHeight:Number;
		private var surfaces:Vector.<SurfaceElement>;
		private var actions:Vector.<ActionElement>;
		private var sprite:Sprite;
		
		/**
		 * For specifying by position and size
		 * @param	blockInfo
		 * @param	world
		 */
		public function Block(blockInfo:BlockInfo, world:b2World):void {
			var pos:b2Vec2 = blockInfo.pixels ? new b2Vec2(
				blockInfo.x / PhysicsUtils.PIXELS_PER_METER, 
				blockInfo.y / PhysicsUtils.PIXELS_PER_METER)
				: new b2Vec2(blockInfo.x, blockInfo.y);

			bodyWidth = blockInfo.pixels ? blockInfo.width
				/ PhysicsUtils.PIXELS_PER_METER : blockInfo.width;
			bodyHeight = blockInfo.pixels ? blockInfo.height
				/ PhysicsUtils.PIXELS_PER_METER : blockInfo.height;

			// if in pixels offset for upper-left origin
			if(blockInfo.pixels) {
				pos.x += bodyWidth / 2;
				pos.y += bodyHeight / 2;
			}

			movement = blockInfo.movement;

			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(bodyWidth / 2, bodyHeight / 2);

			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED 
				? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			rectDef.position.Set(pos.x, pos.y);
			rectDef.angle = 0.0;
			m_physics = world.CreateBody(rectDef);

			var fd:b2FixtureDef = new b2FixtureDef();
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			m_physics.CreateFixture(fd);
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);

			var i:int = 0;

			sprite = new Sprite();
			sprite.graphics.beginFill(movement == FIXED ? 0x999999 : 
				0x333333);
			if(blockInfo.pixels)
				sprite.graphics.drawRect(-blockInfo.width/2, -blockInfo.height/2, 
					blockInfo.width, blockInfo.height);
			else
				sprite.graphics.drawRect(
					0,
					0,
					blockInfo.width * PhysicsUtils.PIXELS_PER_METER,	
					blockInfo.height * PhysicsUtils.PIXELS_PER_METER
				);
			sprite.graphics.endFill();
			addChild(sprite);

			for (i = 0; i < blockInfo.surfaces.length; i++) {
				addSurface(blockInfo.surfaces[i], rectDef, world);
				rectDef.position.Set(pos.x, pos.y);
			}
			for (i = 0; i < blockInfo.actions.length; i++) {
				addAction(blockInfo.actions[i], world);
			}
			
			rectDef.position.Set(rectDef.position.x, rectDef.position.y - bodyHeight);
			var se:SurfaceElement = new Ground(rectDef, bodyWidth, SurfaceElement.DEPTH, world);
			var joint:b2WeldJointDef = new b2WeldJointDef();
			joint.Initialize(m_physics, se.getPhysics(), rectDef.position);
			world.CreateJoint(joint);
			addChild(se);
		}
		
		private function addSurface(key:String, rectDef:b2BodyDef, world:b2World):void {
			var split:int = key.search(",");
			//trace(key);
			//trace(split);
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			var se:SurfaceElement;
			//trace(dir);
			//trace(type);
			if (dir == UP) {
				rectDef.position.Set(rectDef.position.x, rectDef.position.y - bodyHeight / 2);
				se = SurfaceElement.getRelatedType(type, rectDef, bodyWidth, SurfaceElement.DEPTH, world);				
			}else if (dir == DOWN) {
				rectDef.position.Set(rectDef.position.x, rectDef.position.y + bodyHeight / 2);
				se = SurfaceElement.getRelatedType(type, rectDef, bodyWidth, SurfaceElement.DEPTH, world);
			}else if (dir == LEFT) {
				rectDef.position.Set(rectDef.position.x - bodyWidth / 2, rectDef.position.y);
				se = SurfaceElement.getRelatedType(type, rectDef, SurfaceElement.DEPTH, bodyHeight, world);
			}else if (dir == RIGHT) {
				rectDef.position.Set(rectDef.position.x  + bodyWidth / 2, rectDef.position.y - bodyHeight / 2);
				se = SurfaceElement.getRelatedType(type, rectDef, SurfaceElement.DEPTH, bodyHeight, world);
			}
			if(se != null) {
				var joint:b2WeldJointDef = new b2WeldJointDef();
				joint.Initialize(m_physics, se.getPhysics(), rectDef.position);
				world.CreateJoint(joint);
				addChild(se);
			}
		}
		
		private function addAction(key:String, world:b2World):void {
			
		}
		
	}
}
