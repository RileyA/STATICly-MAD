package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class CharacterController {

		private static const MAX_JUMP_COOLDOWN:int=10;
		private static const JUMP_STRENGTH:Number=8.0;
		private static const MOVE_SPEED:Number=4.0;
		private static const ACELL_TIME_CONSTANT:Number=0.5;
		
		private static const MIDAIR_SPEED_FACTOR:Number=0.75;
		
		private var characterBody:b2Body;
		private var jumpImpulse:Number;
		private var jumpCooldown:int;
		private var footContactListener:FootContactListener;

		/**
		* A platforming controller for the specified characterBody
		* that will be acting in the specified levelState.
		*/
		public function CharacterController(levelState:LevelState, characterBody:b2Body):void{
			this.characterBody = characterBody;
			
			jumpCooldown = 0;
			jumpImpulse = -JUMP_STRENGTH * characterBody.GetMass();
			
			var fd:b2FixtureDef = new b2FixtureDef();
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(0.3, 0.2);
			fd.shape = polyShape;
			fd.isSensor = true;
			var footSensorFixture:b2Fixture = characterBody.CreateFixture(fd);
			footSensorFixture.SetUserData(PhysicsUtils.FOOT_SENSOR_ID);
			
			footContactListener = new FootContactListener();
			levelState.world.SetContactListener(footContactListener);
		}
		
		public function updateControls(left:Boolean,right:Boolean,up:Boolean):void{
			jumpCooldown -= 1;
			var xspeed:Number = 0;
			if (left) { xspeed -= MOVE_SPEED; }
			if (right) { xspeed += MOVE_SPEED; }

			if (footContactListener.canJump()) {
				//xspeed *= MIDAIR_SPEED_FACTOR;
				characterBody.GetLinearVelocity().x=xspeed;
			} else if (xspeed!=0) {
				
				var fx:Number=characterBody.GetMass()/ACELL_TIME_CONSTANT;
				var vx:Number=characterBody.GetLinearVelocity().x;
				var deltaSpeed:Number=xspeed-vx;
				fx*=deltaSpeed;
				if ((deltaSpeed*xspeed)>0) {
					characterBody.ApplyForce(new b2Vec2(fx, 0),characterBody.GetWorldCenter());
				}
			}
			
			if (up && footContactListener.canJump() && jumpCooldown<=0) {
				characterBody.ApplyImpulse(new b2Vec2(0, jumpImpulse),
					characterBody.GetWorldCenter());
				// apply a reaction force. TODO : apply at contact location
				var b2:b2Body = footContactListener.lastFootContact;
				b2.ApplyImpulse(new b2Vec2(0, -jumpImpulse),
					b2.GetWorldCenter());
				jumpCooldown = MAX_JUMP_COOLDOWN;
			}
		}
	}
}

import Box2D.Collision.*;
import Box2D.Dynamics.*;
import Box2D.Dynamics.Contacts.*;

class FootContactListener extends b2ContactListener{
	private var numFootContacts:int=0;
	
	public var lastFootContact:b2Body;
	
	public function canJump():Boolean{
		return numFootContacts>0;
	}
	
	public override function BeginContact(contact:b2Contact):void {
		//check if fixture A was the foot sensor
		var fixtureUserData:int = contact.GetFixtureA().GetUserData();
		if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID ){
			numFootContacts++;
			lastFootContact = contact.GetFixtureB().GetBody();
		}
		//check if fixture B was the foot sensor
		fixtureUserData = contact.GetFixtureB().GetUserData();
		if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID ){
			numFootContacts++;
			lastFootContact = contact.GetFixtureA().GetBody();
		}
	}
	
	public override function EndContact(contact:b2Contact):void{
		//check if fixture A was the foot sensor
		var fixtureUserData:int = contact.GetFixtureA().GetUserData();
		if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID )
			numFootContacts--;
		//check if fixture B was the foot sensor
		fixtureUserData = contact.GetFixtureB().GetUserData();
		if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID )
			numFootContacts--;
	}
}
