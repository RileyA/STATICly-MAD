package {
	import Box2D.Dynamics.Joints.*;
	import flash.display.*;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import Surfaces.*;
	import Actioners.*;
	import Chargable.Chargable;
	import Chargable.ChargableUtils;

	public class Block extends GfxPhysObject implements Chargable {
		
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
		public static const strongChargeDensity:Number = 2.0; // charge per square m
		public static const weakChargeDensity:Number = 1.0; // charge per square m

		public static const strongDensity:Number = 10.0; // kg per square m
		public static const weakDensity:Number = 10.0; // kg per square m
		
		private var chargePolarity:int;
		private var drawnChargePolarity:int;
		
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
			
			var area:Number=scale.x*scale.y;//m_physics.GetMass()/fd.density;
			chargeStrength=area*(strong?strongChargeDensity:weakChargeDensity);
			
			// make block actionable
			if (!insulated){
				function act(state:LevelState):void{
					var player:Player= state.getPlayer();
					if (strong) {
						if (chargePolarity==-player.chargePolarity) {
							chargePolarity=ChargableUtils.CHARGE_NONE;
							player.groundPlayer();
						} else {
							var tmp:int=player.chargePolarity;
							player.chargePolarity=chargePolarity;
							chargePolarity=tmp;
						}
					} else { // make weak block copy players state, even if no charge
						chargePolarity=player.chargePolarity;
					}
				}
				function ck(player:Player):Boolean{ return chargePolarity!=player.chargePolarity;}
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
			sprite.graphics.beginFill(strong ? 0x333333 : 0x999999);
			if (movement == FIXED) {
				sprite.graphics.drawRect(-scale.x / 2, -scale.y / 2, scale.x, scale.y);
			} else {
				sprite.graphics.drawRoundRect(-scale.x / 2, -scale.y / 2, scale.x, scale.y, scale.x/2);
			}
			sprite.graphics.endFill();
			redraw();
			addChild(sprite);

			var i:int = 0;

			for (i = 0; i < blockInfo.surfaces.length; i++) {
				rectDef.position.Set(position.x, position.y);
				addSurface(blockInfo.surfaces[i], rectDef, world);
			}
			for (i = 0; i < blockInfo.actions.length; i++) {
				addAction(blockInfo.actions[i], world);
			}
			
			if (movement == TRACKED) {
				var hold:Vector.<Number> = new Vector.<Number>();
				hold.push(0, 18, 26.66, 18);
				makeTracked(blockInfo.bounds, world);
			}
			
		}
		
		public override function updateTransform(pixelsPerMeter:Number):void {
			super.updateTransform(pixelsPerMeter);
			if (drawnChargePolarity!=chargePolarity) {
				redraw();
			}
		}
		
		private function redraw():void{
			ChargableUtils.matchColorToPolarity(sprite, chargePolarity);
			drawnChargePolarity=chargePolarity;
		}
		
		public function getCharge():Number{
			return chargePolarity*chargeStrength;
		}
		
		public function getBody():b2Body{
			return m_physics;
		}

		public function isChargableBlock():Boolean {
			return !(chargePolarity == ChargableUtils.CHARGE_NONE && insulated)
		}
		
		private function addSurface(key:String, rectDef:b2BodyDef, world:b2World):void {
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			var se:SurfaceElement;

			if (dir == UP) {
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(0, -scale.y / 2), 
													scale.x, SurfaceElement.DEPTH, world);			
			}else if (dir == DOWN) {
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(0, scale.y / 2), 
													scale.x, SurfaceElement.DEPTH, world);
			}else if (dir == LEFT) {
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(-scale.x / 2, 0), 
													SurfaceElement.DEPTH, scale.y, world);
			}else if (dir == RIGHT) {
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(scale.x / 2, 0), 
													SurfaceElement.DEPTH, scale.y, world);
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
		
		private function makeTracked(ends:Vector.<UVec2>, world:b2World):void {
			var l:b2Vec2 = ends[0].toB2Vec2();
			var r:b2Vec2 = ends[1].toB2Vec2();
			var axis:b2Vec2 = r.Copy();
			axis.Subtract(l);
			axis.Normalize();
			//trace(axis.x, axis.y);
			var center:b2Vec2 = m_physics.GetPosition().Copy();
			
			var anchorDef:b2BodyDef = new b2BodyDef();
			anchorDef.position = center;
			anchorDef.type = b2Body.b2_staticBody;
			var anchor:b2Body = world.CreateBody(anchorDef);
			
			var trackDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			l.Subtract(center);
			r.Subtract(center);
			trackDef.lowerTranslation = -l.Length();
			trackDef.upperTranslation = r.Length();
			//trackDef.localAnchorA = new b2Vec2(0, 0);
			//trackDef.localAnchorB = new b2Vec2(0, 0);
			//trackDef.collideConnected = false;
			//trackDef.referenceAngle = anchor.GetAngle() - m_physics.GetAngle();
			//trace(trackDef.lowerTranslation, trackDef.upperTranslation);
			//trackDef.maxMotorForce = 1;
			//trackDef.motorSpeed = 0;
			//trackDef.enableMotor = true;
			trackDef.enableLimit = true;
			trackDef.Initialize(anchor, m_physics, new b2Vec2(0, 0), axis);
			world.CreateJoint(trackDef);
		}
	}
}
