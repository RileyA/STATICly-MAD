package {
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import flash.display.*;
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
		private var scale:UVec2;
		private var surfaces:Vector.<SurfaceElement>;
		private var actions:Vector.<ActionerElement>;
		private var sprite:Sprite;
		
		// for charge
		private static const strongChargeDensity:Number = 2.5; // charge per square m
		private static const weakChargeDensity:Number = 1.0; // charge per square m

		private static const strongDensity:Number = 10.0; // kg per square m
		private static const weakDensity:Number = 10.0; // kg per square m
		
		private var chargePolarity:int;
		private var strong:Boolean;
		private var insulated:Boolean;
		
		private var chargeStrength:Number;
		
		/**
		 * @param	blockInfo
		 * @param	world
		 */
		public function Block(blockInfo:BlockInfo, world:b2World):void {

			var position:UVec2 = blockInfo.position.getCopy();
			scale = blockInfo.scale.getCopy();
			movement = blockInfo.movement;
			insulated=blockInfo.insulated;
			strong=blockInfo.strong;
			chargePolarity=blockInfo.chargePolarity;
			
			
			
			
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(scale.x / 2, scale.y / 2);

			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED 
				? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			rectDef.position.Set(position.x, position.y);
			rectDef.angle = 0.0;
			m_physics = world.CreateBody(rectDef);

			var fd:b2FixtureDef = new b2FixtureDef();
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			fd.userData = LevelContactListener.JUMPABLE_ID;
			m_physics.CreateFixture(fd);
			
			var area:Number=m_physics.GetMass()/fd.density;
			chargeStrength=area*(strong?strongChargeDensity:weakChargeDensity);
			
			// make block actionable
			if (!insulated){
				function act():void{}
				function ck(player:Player):Boolean{ return true;}
				fd.userData = new ActionMarker(act,ck);
				m_physics.CreateFixture(fd);
			}
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);

			sprite = new Sprite();
			if (insulated){
				sprite.graphics.lineStyle(3.0,0xDDDD44,1.0,false,LineScaleMode.NONE);
			}
			sprite.graphics.beginFill(strong ? 0x999999 : 0x333333);
			if (movement == FIXED) {
				sprite.graphics.drawRect(-scale.x / 2, -scale.y / 2, scale.x, scale.y);
			} else {
				sprite.graphics.drawRoundRect(-scale.x / 2, -scale.y / 2, scale.x, scale.y, scale.x/2);
			}
			sprite.graphics.endFill();
			addChild(sprite);

			var i:int = 0;

			for (i = 0; i < blockInfo.surfaces.length; i++) {
				rectDef.position.Set(position.x, position.y);
				addSurface(blockInfo.surfaces[i], rectDef, world);
			}
			for (i = 0; i < blockInfo.actions.length; i++) {
				addAction(blockInfo.actions[i], world);
			}
			
		}
		
		public function getCharge():Number{
			return chargePolarity*chargeStrength;
		}
		
		
		private function addSurface(key:String, rectDef:b2BodyDef, world:b2World):void {
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			var se:SurfaceElement;

			if (dir == UP) {
				rectDef.position.Set(rectDef.position.x, rectDef.position.y - scale.y / 2);
				se = SurfaceElement.getRelatedType(type, rectDef, scale.x, SurfaceElement.DEPTH, world);				
			}else if (dir == DOWN) {
				rectDef.position.Set(rectDef.position.x, rectDef.position.y + scale.y / 2);
				se = SurfaceElement.getRelatedType(type, rectDef, scale.x, SurfaceElement.DEPTH, world);
			}else if (dir == LEFT) {
				rectDef.position.Set(rectDef.position.x - scale.x / 2, rectDef.position.y);
				se = SurfaceElement.getRelatedType(type, rectDef, SurfaceElement.DEPTH, scale.y, world);
			}else if (dir == RIGHT) {
				rectDef.position.Set(rectDef.position.x  + scale.x / 2, rectDef.position.y - scale.y / 2);
				se = SurfaceElement.getRelatedType(type, rectDef, SurfaceElement.DEPTH, scale.y, world);
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
