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
		private var anchor:GfxPhysObject;
		private var joints:Vector.<b2Joint>;
		
		// for charge
		public static const strongChargeDensity:Number = 2.0; // charge per square m
		public static const weakChargeDensity:Number = 1.0; // charge per square m

		public static const strongDensity:Number = 20.0; // kg per square m
		public static const weakDensity:Number = 12.0; // kg per square m
		
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
			fd.density = strong?strongDensity:weakDensity;
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
						LoggerUtils.logChargeStrong(player.chargePolarity, chargePolarity);
						if (chargePolarity==-player.chargePolarity) {
							chargePolarity=ChargableUtils.CHARGE_NONE;
							player.groundPlayer();
						} else {
							var tmp:int=player.chargePolarity;
							player.chargePolarity=chargePolarity;
							chargePolarity=tmp;
						}
					} else { // make weak block copy players state, even if no charge
						LoggerUtils.logChargeWeak(player.chargePolarity, chargePolarity);
						chargePolarity=player.chargePolarity;
					}
				}
				function ck(player:Player):Boolean{ return chargePolarity!=player.chargePolarity;}
				fd.density=0;
				var fix:b2Fixture=m_physics.CreateFixture(fd);
				fix.SetUserData(new ActionMarker(act,ck,fix,this));
			}
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);

			sprite = new Sprite();
			if (insulated){
				sprite.graphics.lineStyle(3.0,0xFFFFBB,1.0,false,LineScaleMode.NONE);
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
			
			anchor = null;
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
			if(anchor != null){
				m_level.getParent().removeChild(anchor);
			}
		}

		/** deinit and reinit to reflect any changes in blockinfo */
		public function reinit():void {
			deinit();
			// if it's in the charge manager, nuke it
			m_level.getChargableManager().removeChargable(this);
			
			init();
			
			// then re-add if need be
			if (isChargableBlock())
				m_level.getChargableManager().addChargable(this);
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
			if (anchor != null) {
				anchor.updateTransform(pixelsPerMeter);
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
		
		public function getMovement():String {
			return movement;
		}
		
		public function getAnchor():GfxPhysObject {
			return anchor;
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
			var tokens:Array = key.split(",", 3);
			var dir:String = tokens[0];
			var type:String = tokens[1];
			var extra:String = null;
			if (tokens.length > 2) {
				extra = tokens[2];
			}
			var ae:ActionerElement;

			switch (dir) {
			case UP:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(0, -scale.y / 2), extra, world);
				break;
			case DOWN:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(0, scale.y / 2), extra, world);
				break;
			case LEFT:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(-scale.x / 2, 0), extra, world);
				break;
			case RIGHT:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(scale.x / 2, 0), extra, world);
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
			
			var center:b2Vec2 = m_physics.GetPosition().Copy();
			var trackDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			
			
			
			var slope:b2Vec2 = ends[0].toB2Vec2();
			slope.Normalize();
			var weights:b2Vec2 = ends[1].toB2Vec2();
			
			if (weights.x > weights.y) {
				var hold:Number = weights.y;
				weights.y = weights.x;
				weights.x = hold;
			}
			
			var l:b2Vec2 = new b2Vec2(weights.x * slope.x, weights.x * slope.y); 
			var r:b2Vec2 = new b2Vec2(weights.y * slope.x, weights.y * slope.y);
			var axis:b2Vec2 = slope.Copy();
			trackDef.lowerTranslation = weights.x;
			trackDef.upperTranslation = weights.y;
			
			//var l:b2Vec2 = ends[0].toB2Vec2();
			//var r:b2Vec2 = ends[1].toB2Vec2();
			//var axis:b2Vec2 = l.Copy();
			//axis.Subtract(r);
			//trackDef.lowerTranslation = -l.Length();
			//trackDef.upperTranslation = r.Length();
						
			axis.Normalize();
			
			var anchorDef:b2BodyDef = new b2BodyDef();
			anchorDef.position = center.Copy();
			anchorDef.type = b2Body.b2_staticBody;
			var anchorBody:b2Body = m_level.world.CreateBody(anchorDef);
			anchor = new GfxPhysObject(anchorBody);
			trackDef.enableLimit = true;
			trackDef.Initialize(anchorBody, m_physics, center, axis);
			joints.push(m_level.world.CreateJoint(trackDef));
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xB0B0B0);
			sprite.graphics.lineStyle(3.0, 0x333333, .8, false, LineScaleMode.NONE);
			sprite.graphics.moveTo(l.x, l.y);
			sprite.graphics.lineTo(r.x, r.y);
			sprite.graphics.drawCircle(l.x, l.y, 0.1);
			sprite.graphics.drawCircle(r.x, r.y, 0.1);
			sprite.graphics.endFill();
			
			anchor.addChild(sprite);
			
			
			m_level.getParent().addChild(anchor);
			
			sprite = new Sprite();
			sprite.graphics.beginFill(0xB0B0B0);
			sprite.graphics.lineStyle(3.0, 0x333333, .8, false, LineScaleMode.NONE);
			
			var dy:Number = r.y - l.y;
			var dx:Number = r.x - l.x;
			var length:Number = 5 * Math.sqrt((dy * dy) + (dx * dx));
			sprite.graphics.moveTo(l.y / length, l.x / length);
			sprite.graphics.lineTo(r.y / length, r.x / length);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		public function getBodyType():uint {
			return movement == FIXED ? b2Body.b2_staticBody 
				: b2Body.b2_dynamicBody;
		}
	}
}
