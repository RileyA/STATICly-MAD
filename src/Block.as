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
	import Chargable.*;

	public class Block extends GfxPhysObject implements Chargable {
		
		public static const FREE:String = "free";
		public static const TRACKED:String = "tracked";
		public static const FIXED:String = "fixed";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		
		private var movement:String;
		private var scale:UVec2;
		private var surfaces:Vector.<SurfaceElement>;
		private var actioners:Vector.<ActionerElement>;
		private var sprite:Sprite;
		private var joints:Vector.<b2Joint>;
		
		// for charge
		public static const strongChargeDensity:Number = 2.0; // charge per square m
		public static const weakChargeDensity:Number = 1.0; // charge per square m

		public static const strongDensity:Number = 10.0; // kg per square m
		public static const weakDensity:Number = 3.0; // kg per square m
		
		private var chargePolarity:int;
		private var drawnChargePolarity:int;
		
		private var strong:Boolean;
		private var insulated:Boolean;
		
		private var charges:Vector.<Charge>;

		// somewhat hacky... but it prevents having to pass the level in
		// when reinit-ing blocks in the editor, and presumably a block
		// will only ever belong to a single level at once...
		private var m_level:Level = null;
		private var m_info:BlockInfo;
		
		/**
		 * @param	blockInfo Info struct containing various block properties
		 * @param	level The level this block lives in
		 */
		public function Block(blockInfo:BlockInfo, level:Level):void {
			m_level= level;
			m_info = blockInfo;
			init();
		}

		public function init():void {

			joints = new Vector.<b2Joint>();
			surfaces = new Vector.<SurfaceElement>();
			actioners = new Vector.<ActionerElement>();

			var position:UVec2 = m_info.position.getCopy();
			scale = m_info.scale.getCopy();
			movement = m_info.movement;
			insulated=m_info.insulated;
			strong=m_info.strong;
			chargePolarity=m_info.chargePolarity;
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(scale.x / 2, scale.y / 2);

			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED 
				? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			rectDef.position.Set(position.x, position.y);
			rectDef.angle = 0.0;
			m_physics = m_level.world.CreateBody(rectDef);

			var fd:b2FixtureDef = new b2FixtureDef();
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			fd.userData = LevelContactListener.JUMPABLE_ID;
			m_physics.CreateFixture(fd);
			
			var area:Number=scale.x*scale.y;//m_physics.GetMass()/fd.density;
			var chargeStrength:Number=area*(strong?strongChargeDensity:weakChargeDensity);
			this.charges=ChargableUtils.makeCharges(chargeStrength, -scale.x / 2, -scale.y / 2, scale.x / 2, scale.y / 2);
			//this.charges=new Vector.<Charge>();
			//this.charges.push(new Charge(chargeStrength,new b2Vec2(0,0)));
			
			
			// make block actionable
			if (!insulated){
				function act(m_level:Level):void{
					var player:Player= m_level.getPlayer();
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
				var fix:b2Fixture=m_physics.CreateFixture(fd);
				fix.SetUserData(new ActionMarker(act,ck,fix));
			}
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);

			sprite = new Sprite();
			if (insulated){
				sprite.graphics.lineStyle(3.0,0xDDDD44,1.0,false,LineScaleMode.NONE);
			}
			sprite.graphics.beginFill(strong ? 0x333333 : 0xBBBBBB);
			if (movement == FIXED) {
				sprite.graphics.drawRect(-scale.x / 2, -scale.y / 2, scale.x, scale.y);
			} else {
				sprite.graphics.drawRoundRect(-scale.x / 2, -scale.y / 2, scale.x, scale.y, .8);
			}
			sprite.graphics.endFill();
			redraw();
			addChild(sprite);

			var i:int = 0;

			for (i = 0; i < m_info.surfaces.length; i++) {
				rectDef.position.Set(position.x, position.y);
				addSurface(m_info.surfaces[i], rectDef, m_level.world);
			}
			for (i = 0; i < m_info.actions.length; i++) {
				rectDef.position.Set(position.x, position.y);
				addActioner(m_info.actions[i], rectDef, m_level.world);
			}
			
			if (movement == TRACKED) {
				makeTracked(m_info.bounds);
			}
		}

		// helper that cleans up a block
		public function deinit():void {
			for (var i:uint = 0; i < surfaces.length; ++i)
				surfaces[i].cleanup();
			for (i = 0; i < actioners.length; ++i)
				actioners[i].cleanup();
			var world:b2World = m_physics.GetWorld();
			world.DestroyBody(m_physics);
			for (i = 0; i < joints.length; ++i)
				world.DestroyJoint(joints[i]);
			while (numChildren > 0)
				removeChildAt(0);
			joints = new Vector.<b2Joint>();
			surfaces = new Vector.<SurfaceElement>();
			actioners = new Vector.<ActionerElement>();
		}

		/** deinit and reinit to reflect any changes in blockinfo */
		public function reinit():void {
			deinit();
			// if it's in the charge manager, nuke it
			m_level.getChargableManager().removeChargable(this);
			// then re-add if need be
			if (isChargableBlock())
				m_level.getChargableManager().addChargable(this);
			init();
		}

		public function resetCharge():void {
			chargePolarity = m_info.chargePolarity;
		}

		public function getInfo():BlockInfo {
			return m_info;
		}
		
		public override function updateTransform(pixelsPerMeter:Number):void {
			super.updateTransform(pixelsPerMeter);
			if (drawnChargePolarity!=chargePolarity) {
				redraw();
			}
		}

		public function setPosition(pos:UVec2):void {
			m_physics.SetPosition(pos.toB2Vec2());
			m_physics.SetAwake(true);
		}

		public function clearVelocity():void {
			m_physics.SetLinearVelocity(new b2Vec2(0,0));
			m_physics.SetAngularVelocity(0.0);
			m_physics.SetAngle(0);
		}

		public function getScale():UVec2 {
			return scale.getCopy();
		}
		
		private function redraw():void{
			ChargableUtils.matchColorToPolarity(sprite, chargePolarity);
			drawnChargePolarity=chargePolarity;
		}
		
		public function getCharge():Number{
			return chargePolarity;
		}
		
		public function getCharges():Vector.<Charge>{
			return charges;
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

			switch (dir) {
			case UP:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(0, -scale.y / 2), 
													scale.x, SurfaceElement.DEPTH, world);			
				break;
			case DOWN:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(0, scale.y / 2), 
													scale.x, SurfaceElement.DEPTH, world);
				break;
			case LEFT:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(-scale.x / 2, 0), 
													SurfaceElement.DEPTH, scale.y, world);
				break;
			case RIGHT:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(scale.x / 2, 0), 
													SurfaceElement.DEPTH, scale.y, world);
				break;
			default:
				se == null;
			}
			if(se != null) {
				var joint:b2WeldJointDef = new b2WeldJointDef();
				joint.Initialize(m_physics, se.getPhysics(), rectDef.position);
				joints.push(world.CreateJoint(joint));
				surfaces.push(se);
				addChild(se);
			}
		}

		private function addActioner(key:String, rectDef:b2BodyDef, world:b2World):void {
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			var ae:ActionerElement;
			var am:ActionMarker;

			switch (dir) {
			case UP:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(0, -scale.y / 2), am, world);
				break;
			case DOWN:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(0, scale.y / 2), am, world);
				break;
			case LEFT:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(-scale.x / 2, 0), am, world);
				break;
			case RIGHT:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(scale.x / 2, 0), am, world);
				break;
			default:
				ae == null;
			}
			if(ae != null) {
				var joint:b2WeldJointDef = new b2WeldJointDef();
				joint.Initialize(m_physics, ae.getPhysics(), rectDef.position);
				joints.push(world.CreateJoint(joint));
				actioners.push(ae);
				addChild(ae);
			}
		}

		private function removeActions():void {
			// TODO
		}
		
		private function makeTracked(ends:Vector.<UVec2>):void {
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
			var anchor:b2Body = m_level.world.CreateBody(anchorDef);
			
			var trackDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			//l.Subtract(center);
			//r.Subtract(center);
			trackDef.lowerTranslation = -l.Length();
			trackDef.upperTranslation = r.Length();
			trackDef.enableLimit = true;
			trackDef.Initialize(anchor, m_physics, center, axis);
			joints.push(m_level.world.CreateJoint(trackDef));
		}

		public function getBodyType():uint {
			return movement == FIXED ? b2Body.b2_staticBody 
				: b2Body.b2_dynamicBody;
		}
	}
}
