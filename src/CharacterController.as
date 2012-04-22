package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class CharacterController extends Block{
		private static const jumpStrength:Number=3.0;
		private static const moveSpeed:Number=2.0;
		
		private var jumpImpulse:Number;
		private var footContactListener:FootContactListener;

		
		public function CharacterController(bm:BlockManager,position:b2Vec2):void{
			var polyShape:b2PolygonShape = new b2PolygonShape();
			
			var w:Number=.7;
			var h:Number=-1.2;
			var hMid:Number=-0.9;
			polyShape.SetAsArray([new b2Vec2(0,h),new b2Vec2(w/2,hMid),new b2Vec2(w/2,0),new b2Vec2(-w/2,0),new b2Vec2(-w/2,hMid)])
			
			super(bm,position,polyShape,Block.charge_none,true,true,true);
			
			body.SetFixedRotation(true);
			jumpImpulse=-jumpStrength*body.GetMass();
			
			
			// setup contact sense for jumping
			// http://www.iforce2d.net/b2dtut/jumpability
			//add foot sensor fixture
			var fd:b2FixtureDef = new b2FixtureDef();
			polyShape.SetAsBox(0.3, 0.1);
			fd.shape = polyShape;
			fd.isSensor = true;
			var footSensorFixture:b2Fixture = body.CreateFixture(fd);
			footSensorFixture.SetUserData(flag_footSensor);
			
			footContactListener=new FootContactListener();
			bm.world.SetContactListener(footContactListener);
			
		}
		
		public function updateControls(left:Boolean,right:Boolean,up:Boolean):void{
			var xspeed:Number=0;
			if (left) { xspeed-=moveSpeed; }
			if (right) { xspeed+=moveSpeed; }
			
			if (xspeed!=0) {
				body.SetLinearVelocity(new b2Vec2(xspeed,body.GetLinearVelocity().y));
			}
			
			if (up && footContactListener.canJump()){
				body.ApplyImpulse(new b2Vec2(0,jumpImpulse),body.GetWorldCenter());
				
				// apply a reaction force. TODO : apply at contact location
				var b2:b2Body=footContactListener.lastFootContact;
				b2.ApplyImpulse(new b2Vec2(0,-jumpImpulse),b2.GetWorldCenter());

			}
			
		}
	}
}

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
}
