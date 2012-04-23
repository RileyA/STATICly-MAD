package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class CharacterController {

		private static const maxJumpCooldown:int=10;
		private static const jumpStrength:Number=8.0;
		private static const moveSpeed:Number=2.0;
		
		private var characterBody:b2Body;
		private var jumpImpulse:Number;
		private var jumpCooldown:int;
		//private var footContactListener:FootContactListener;
		
		/**
		* A platforming controller for the specified characterBody
		* that will be acting in the specified levelState.
		*/
		public function CharacterController(levelState:LevelState, characterBody:b2Body):void{
			this.characterBody = characterBody;
			
			//characterBody.SetFixedRotation(true);
			//characterBody.SetLinearDamping(1.0);
			jumpCooldown=0;
			
			jumpImpulse=-jumpStrength*characterBody.GetMass();
			
			// setup contact sense for jumping
			// http://www.iforce2d.net/b2dtut/jumpability
			//add foot sensor fixture
			var fd:b2FixtureDef = new b2FixtureDef();
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(0.3, 0.2);
			fd.shape = polyShape;
			fd.isSensor = true;
			var footSensorFixture:b2Fixture = characterBody.CreateFixture(fd);
			footSensorFixture.SetUserData(0);
			
			//footContactListener=new FootContactListener();
			//levelState.world.SetContactListener(footContactListener);
			
		}
		
		public function updateControls(left:Boolean,right:Boolean,up:Boolean):void{
			jumpCooldown-=1;
			var xspeed:Number=0;
			if (left) { xspeed-=moveSpeed; }
			if (right) { xspeed+=moveSpeed; }
			
			if (xspeed!=0) {
				characterBody.SetLinearVelocity(new b2Vec2(xspeed,characterBody.GetLinearVelocity().y));
			}
			
			/*if (up && footContactListener.canJump() && jumpCooldown<=0){
				characterBody.ApplyImpulse(new b2Vec2(0,jumpImpulse),characterBody.GetWorldCenter());
				
				// apply a reaction force. TODO : apply at contact location
				var b2:b2Body=footContactListener.lastFootContact;
				b2.ApplyImpulse(new b2Vec2(0,-jumpImpulse),b2.GetWorldCenter());
				
				jumpCooldown=maxJumpCooldown;
			}*/
			
		}
	}
}

/*import Box2D.Dynamics.*;
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
		if (fixtureUserData == Block.flag_footSensor ){
			numFootContacts++;
			lastFootContact=contact.GetFixtureB().GetBody();
		}
		//check if fixture B was the foot sensor
		fixtureUserData = contact.GetFixtureB().GetUserData();
		if (fixtureUserData == Block.flag_footSensor ){
			numFootContacts++;
			lastFootContact=contact.GetFixtureA().GetBody();
		}
	}
	
	public override function EndContact(contact:b2Contact):void{
		//check if fixture A was the foot sensor
		var fixtureUserData:int = contact.GetFixtureA().GetUserData();
		if (fixtureUserData == Block.flag_footSensor )
			numFootContacts--;
		//check if fixture B was the foot sensor
		fixtureUserData = contact.GetFixtureB().GetUserData();
		if (fixtureUserData == Block.flag_footSensor )
			numFootContacts--;
	}
}*/
