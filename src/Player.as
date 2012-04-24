package {

	import GfxPhysObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	import flash.ui.Keyboard;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Chargable.Chargable;

	public class Player extends GfxPhysObject { //implements Chargable {

		private static const MAX_JUMP_COOLDOWN:int=10;
		private static const JUMP_STRENGTH:Number=8.0;
		private static const MOVE_SPEED:Number=6.0;
		private static const ACELL_TIME_CONSTANT:Number=0.5;
		
		private var jumpCooldown:int;
		private var m_sprite:Sprite;

		private static const LEFT_KEY:Number = Keyboard.LEFT;
		private static const RIGHT_KEY:Number = Keyboard.RIGHT;
		private static const JUMP_KEY:Number = Keyboard.UP;
		private static const ACTION_KEY:Number = Keyboard.DOWN;

		public function Player(levelState:LevelState, position:b2Vec2):void {

			var polyShape:b2PolygonShape = new b2PolygonShape();
			var w:Number=.7;
			var h:Number=-1.2;
			var hMid:Number=-0.9;
			polyShape.SetAsArray([new b2Vec2(0,h),new b2Vec2(w/2,hMid),
				new b2Vec2(w/2,0),new b2Vec2(-w/2,0),new b2Vec2(-w/2,hMid)])

			var fd:b2FixtureDef = new b2FixtureDef();
			var ccDef:b2BodyDef = new b2BodyDef();
			ccDef.type = b2Body.b2_dynamicBody;
			ccDef.allowSleep = false;
			ccDef.awake = true;
			ccDef.position = position;
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			fd.userData = "player";
			m_physics = levelState.world.CreateBody(ccDef);
			m_physics.CreateFixture(fd);
			m_physics.SetFixedRotation(true);
			m_physics.SetLinearDamping(.2);

			// placeholder sprite to be replaced with an animated MovieClip at some point...
			m_sprite = new Sprite();
			m_sprite.graphics.beginFill(0xff0000);
			m_sprite.graphics.drawRect(
				PhysicsUtils.PIXELS_PER_METER * -w/2.0,
				h * PhysicsUtils.PIXELS_PER_METER,
				w * PhysicsUtils.PIXELS_PER_METER,
				h * -PhysicsUtils.PIXELS_PER_METER);
			m_sprite.graphics.endFill();
			addChild(m_sprite);
			
			jumpCooldown = 0;
			
			fd = new b2FixtureDef();
			polyShape = new b2PolygonShape();
			polyShape.SetAsBox(0.3, 0.2);
			fd.shape = polyShape;
			fd.isSensor = true;
			var footSensorFixture:b2Fixture = m_physics.CreateFixture(fd);
			footSensorFixture.SetUserData(LevelContactListener.FOOT_SENSOR_ID);
		}

		public function update(state:LevelState):void {
			var left:Boolean=Keys.isKeyPressed(Keyboard.LEFT);
			var right:Boolean=Keys.isKeyPressed(Keyboard.RIGHT);
			var up:Boolean=Keys.isKeyPressed(Keyboard.UP);
			var action:Boolean=Keys.isKeyPressed(Keyboard.DOWN);
			
			jumpCooldown -= 1;
			var xspeed:Number = 0;
			if (left) { xspeed -= MOVE_SPEED; }
			if (right) { xspeed += MOVE_SPEED; }

			if (state.contactListener.canJump()) {
				m_physics.GetLinearVelocity().x=xspeed;
			} else if (xspeed!=0) {
				
				var fx:Number=m_physics.GetMass()/ACELL_TIME_CONSTANT;
				var vx:Number=m_physics.GetLinearVelocity().x;
				var deltaSpeed:Number=xspeed-vx;
				fx*=deltaSpeed;
				if ((deltaSpeed*xspeed)>0) {
					m_physics.ApplyForce(new b2Vec2(fx, 0),m_physics.GetWorldCenter());
				}
			}
			
			if (up && state.contactListener.canJump() && jumpCooldown<=0) {
				var jumpImpulse:Number = -JUMP_STRENGTH * m_physics.GetMass();
				m_physics.ApplyImpulse(new b2Vec2(0, jumpImpulse),
					m_physics.GetWorldCenter());
				// apply a reaction force. TODO : apply at contact location
				var b2:b2Body = state.contactListener.lastFootContact;
				
				b2.ApplyImpulse(new b2Vec2(0, -jumpImpulse),
					b2.GetWorldCenter());
				jumpCooldown = MAX_JUMP_COOLDOWN;
			}
			
			updateTransform();
		}
		
	}
}
