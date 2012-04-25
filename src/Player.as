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
	import Actioners.*;

	public class Player extends GfxPhysObject { //implements Chargable {

		private static const JUMP_STRENGTH:Number=8.0;
		private static const MOVE_SPEED:Number=6.0;
		private static const ACELL_TIME_CONSTANT:Number=0.5;
		
		private var m_sprite:Sprite;

		private static const LEFT_KEY:Number = Keyboard.LEFT;
		private static const RIGHT_KEY:Number = Keyboard.RIGHT;
		private static const JUMP_KEY:Number = Keyboard.UP;
		private static const ACTION_KEY:Number = Keyboard.DOWN;

		public function Player(levelState:LevelState, position:UVec2):void {

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
			ccDef.position = position.toB2Vec2();
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			fd.userData = LevelContactListener.PLAYER_BODY_ID;
			m_physics = levelState.world.CreateBody(ccDef);
			m_physics.CreateFixture(fd);
			m_physics.SetFixedRotation(true);
			m_physics.SetLinearDamping(.2);

			// placeholder sprite to be replaced with an animated MovieClip at some point...
			m_sprite = new Sprite();
			m_sprite.graphics.beginFill(0xff0000);
			m_sprite.graphics.drawRect(-w/2.0, h, w, -h);
			m_sprite.graphics.endFill();
			addChild(m_sprite);
			
			fd = new b2FixtureDef();
			polyShape = new b2PolygonShape();
			polyShape.SetAsBox(0.3, 0.2);
			fd.shape = polyShape;
			fd.isSensor = true;
			fd.userData = LevelContactListener.FOOT_SENSOR_ID;
			m_physics.CreateFixture(fd);
		}
		
		

		
		
		public function update(state:LevelState):void {
			function groundFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.GROUND_SENSOR_ID &&
					(b==LevelContactListener.FOOT_SENSOR_ID ||
					 b==LevelContactListener.PLAYER_BODY_ID );
			}
			var isGrounded:Boolean=PhysicsUtils.getCollosions(m_physics,groundFilter).length>0;
			
			if (isGrounded) {
				// TODO : zero charge
			}
			
			function jumpFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.JUMPABLE_ID && b==LevelContactListener.FOOT_SENSOR_ID;
			}
			var canJump:Boolean=PhysicsUtils.getCollosions(m_physics,jumpFilter).length>0;
			
			
			function actionFilter(a:*,b:*):Boolean{
				return (a is ActionMarker && b==LevelContactListener.PLAYER_ACTION_ID);
			}
			var markers:Vector.<*>=PhysicsUtils.getCollosions(m_physics,groundFilter);
			
			// TODO : do something with the action markers
			
			
			
			var left:Boolean=Keys.isKeyPressed(Keyboard.LEFT);
			var right:Boolean=Keys.isKeyPressed(Keyboard.RIGHT);
			var up:Boolean=Keys.isKeyPressed(Keyboard.UP);
			var action:Boolean=Keys.isKeyPressed(Keyboard.DOWN);
			
			var xspeed:Number = 0;
			if (left) { xspeed -= MOVE_SPEED; }
			if (right) { xspeed += MOVE_SPEED; }

			if (canJump) {
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
			
			if (up && canJump) {
				m_physics.GetLinearVelocity().y=-JUMP_STRENGTH;
			}
		}
	}
}
