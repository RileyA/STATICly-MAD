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
		public var lastFootContact:b2Body;
		
		public static const FOOT_SENSOR_ID:int=1;
		
		public function LevelContactListener() {
			actionCandidates = new Vector.<GfxPhysObject>();
		}
		
		public function getBestAction(player:Player):GfxPhysObject {
			holder = player;
			actionCandidates.sort(compare);
			holder = null;
			return actionCandidates[0];
		}
		
		public function canJump():Boolean{
			return numFootContacts>0;
		}
		
		// returns True if handled
		private function doBeginContact(a:b2Fixture, b:b2Fixture):Boolean{
			if (a.GetUserData() == Player && false) {
				actionCandidates.push(b.GetUserData());
				return true;
			} else if (a.GetUserData() == FOOT_SENSOR_ID){
				numFootContacts++;
				lastFootContact = b.GetBody();
				return true;
			}
			return false;
		}
		
		// returns True if handled
		private function doEndContact(a:b2Fixture, b:b2Fixture):Boolean{
			if (a.GetUserData() == Player && false) {
				holder=b.GetUserData();
				actionCandidates = actionCandidates.filter(removeFunc);
				holder = null;
				return true;
			} else if (a.GetUserData() == FOOT_SENSOR_ID){
				numFootContacts--;
				//if (lastFootContact == b.GetBody() && numFootContacts>0){ // TODO : make this not happen
				//	throw new Error("Assertion failed!: LevelContactListener");
				//}
				return true;
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
