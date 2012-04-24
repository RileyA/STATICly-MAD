package  
{
	import Box2D.Collision.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Surfaces.*;
	import Actioners.*;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class LevelContactListener extends b2ContactListener {
		
		private var actionCandidates:Vector.<GfxPhysObject>;
		private var holder:GfxPhysObject;
		
		private var numFootContacts:int=0;
		private var numGroundContacts:int=0;
		
		
		public static const FOOT_SENSOR_ID:int=1;
		public static const GROUND_SENSOR_ID:int=2;
		public static const PLAYER_BODY_ID:int=3;
		
		public function LevelContactListener() {
			actionCandidates = new Vector.<GfxPhysObject>();
		}
		
		public function getBestAction():GfxPhysObject {
			actionCandidates.sort(compare);
			return actionCandidates[0];
		}
		
		public function canJump():Boolean{
			return numFootContacts>0;
		}
		
		public function isGrounded():Boolean{
			return numGroundContacts>0;
		}
		
		// returns True if handled
		private function doBeginContact(a:b2Fixture, b:b2Fixture):Boolean{
			if (a.GetUserData() == Player && false) {
				actionCandidates.push(b.GetUserData());
				return true;
			} else if (a.GetUserData() == FOOT_SENSOR_ID){
				numFootContacts++;
				return true;
			} else if (a.GetUserData() == GROUND_SENSOR_ID){
				if (b.GetUserData() == FOOT_SENSOR_ID || b.GetUserData() == PLAYER_BODY_ID){
					numGroundContacts++;
					return true;
				}
			}
			return false;
		}
		
		// returns True if handled
		private function doEndContact(a:b2Fixture, b:b2Fixture):Boolean{
			if (a.GetUserData() == Player && false) {
				holder=b.GetUserData();
				actionCandidates = actionCandidates.filter(removeFunc);
				return true;
			} else if (a.GetUserData() == FOOT_SENSOR_ID){
				numFootContacts--;
				return true;
			} else if (a.GetUserData() == GROUND_SENSOR_ID){
				if (b.GetUserData() == FOOT_SENSOR_ID || b.GetUserData() == PLAYER_BODY_ID){
					numGroundContacts--;
					return true;
				}
			}
			return false;
		}
		
		
		public override function BeginContact(contact:b2Contact):void {
			if (!doBeginContact(contact.GetFixtureA(),contact.GetFixtureB())) {
				if (!doBeginContact(contact.GetFixtureB(),contact.GetFixtureA())) {
					// other handlers
				}
			}
		}
		
		public override function EndContact(contact:b2Contact):void {
			if (!doEndContact(contact.GetFixtureA(),contact.GetFixtureB())) {
				if (!doEndContact(contact.GetFixtureB(),contact.GetFixtureA())) {
					// other handlers
				}
			}
		}
		
		private function removeFunc(item:GfxPhysObject):Boolean {
			return item != holder;
		}
		
		private function compare(x:GfxPhysObject, y:GfxPhysObject):Number {
			return 7; // TODO make not stupid
		}
	}

}
