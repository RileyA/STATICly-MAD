package  
{
	import Box2D.Collision.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class LevelContactListener {
		
		public function LevelContactListener() {
			
		}
		
		public override function BeginContact(contact:b2Contact):void {
			if (contact.IsSensor()) {
				
			}
			////check if fixture A was the foot sensor
			//var fixtureUserData:int = contact.GetFixtureA().GetUserData();
			//if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID ){
				//numFootContacts++;
				//lastFootContact = contact.GetFixtureB().GetBody();
			//}
			////check if fixture B was the foot sensor
			//fixtureUserData = contact.GetFixtureB().GetUserData();
			//if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID ){
				//numFootContacts++;
				//lastFootContact = contact.GetFixtureA().GetBody();
			//}
		}
		
		public override function EndContact(contact:b2Contact):void{
			//check if fixture A was the foot sensor
			//var fixtureUserData:int = contact.GetFixtureA().GetUserData();
			//if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID )
				//numFootContacts--;
			//check if fixture B was the foot sensor
			//fixtureUserData = contact.GetFixtureB().GetUserData();
			//if (fixtureUserData == PhysicsUtils.FOOT_SENSOR_ID )
				//numFootContacts--;
		}
	}

}

class FootContactListener extends b2ContactListener{
	private var numFootContacts:int=0;
	
	public var lastFootContact:b2Body;
	
	public function canJump():Boolean{
		return numFootContacts>0;
	}
	
}