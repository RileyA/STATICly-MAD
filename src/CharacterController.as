package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class CharacterController {

		private static const MAX_JUMP_COOLDOWN:int=10;
		private static const JUMP_STRENGTH:Number=8.0;
		private static const MOVE_SPEED:Number=4.0;
		private static const ACELL_TIME_CONSTANT:Number=0.5;
		
		private var characterBody:b2Body;
		private var jumpImpulse:Number;
		private var jumpCooldown:int;

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
			footSensorFixture.SetUserData(LevelContactListener.FOOT_SENSOR_ID);
		}
		
		public function updateControls(state:LevelState,left:Boolean,right:Boolean,up:Boolean):void{
			jumpCooldown -= 1;
			var xspeed:Number = 0;
			if (left) { xspeed -= MOVE_SPEED; }
			if (right) { xspeed += MOVE_SPEED; }

			if (state.contactListener.canJump()) {
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
			
			if (up && state.contactListener.canJump() && jumpCooldown<=0) {
				characterBody.ApplyImpulse(new b2Vec2(0, jumpImpulse),
					characterBody.GetWorldCenter());
				// apply a reaction force. TODO : apply at contact location
				var b2:b2Body = state.contactListener.lastFootContact;
				b2.ApplyImpulse(new b2Vec2(0, -jumpImpulse),
					b2.GetWorldCenter());
				jumpCooldown = MAX_JUMP_COOLDOWN;
			}
		}
	}
}
