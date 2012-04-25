package  
{
	import Box2D.Collision.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Surfaces.*;
	import Actioners.*;
	import Chargable.ChargableUtils;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class LevelContactListener extends b2ContactListener {
		
		private var actionCandidates:Vector.<GfxPhysObject>;
		private var holder:GfxPhysObject;
		
		private var numFootContacts:int;
		private var numGroundContacts:int;
		private var currCarpetPolarity:int;
		
		
		public static const PLAYER_BODY_ID:int=1;
		public static const FOOT_SENSOR_ID:int=2;
		public static const JUMPABLE_ID:int=3;
		public static const GROUND_SENSOR_ID:int=4;
		public static const CARPET_POS_SENSOR_ID:int=5;
		public static const CARPET_NEG_SENSOR_ID:int=6;
		
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
		
		public function isGrounded():Boolean{
			return numGroundContacts>0;
		}

		/**
		* Returns the charge polarity of the any carpet the player is currently
		* touching, or 0 if no carpet is being touched.
		*/
		public function getCarpetPolarity():int{
			return currCarpetPolarity;
		}
		
		// returns True if handled
		private function doBeginContact(a:b2Fixture, b:b2Fixture):Boolean {
			if (a.GetUserData() is Player && b.GetUserData() is ActionMarker) {
				trace("woo!");
				if((ActionMarker)(b.GetUserData()).canAction((Player)(a.GetUserData()))){
					actionCandidates.push(b.GetUserData());
					return true;
				}
			} else if (a.GetUserData() == FOOT_SENSOR_ID && b.GetUserData() == JUMPABLE_ID) {
				numFootContacts++;
				return true;
			} else if (beginContactSurface(a, b)) {
				return true;
			}
			return false;
		}

		/**
		* Handles beginning contact with a surface element.
		* Returns true if a contact was handled.
		*/
		private function beginContactSurface(a:b2Fixture, b:b2Fixture):Boolean {
			switch (a.GetUserData()) {
			case CARPET_POS_SENSOR_ID:
				currCarpetPolarity = ChargableUtils.CHARGE_POS;
				return true;
			case CARPET_NEG_SENSOR_ID:
				currCarpetPolarity = ChargableUtils.CHARGE_NEG;
				return true;
			case GROUND_SENSOR_ID:
				if (b.GetUserData() == FOOT_SENSOR_ID || b.GetUserData() == PLAYER_BODY_ID){
					numGroundContacts++;
					return true;
				}
				break;
			default:
				return false;
			}
			return false;
		}
		
		// returns True if handled
		private function doEndContact(a:b2Fixture, b:b2Fixture):Boolean{
			if (a.GetUserData() is Player && b.GetUserData() is ActionMarker) {
				holder=b.GetUserData();
				actionCandidates = actionCandidates.filter(removeFunc);
				holder = null;
				return true;
			} else if (a.GetUserData() == FOOT_SENSOR_ID){
				numFootContacts--;
				return true;
			} else if (endContactSurface(a, b)) {
				return true;
			}
			return false;
		}
		
		/**
		* Handles ending contact with surface elements.
		* Returns true if a contact was handled.
		*/
		private function endContactSurface(a:b2Fixture, b:b2Fixture):Boolean {
			switch (a.GetUserData()) {
			case CARPET_POS_SENSOR_ID:
			case CARPET_NEG_SENSOR_ID:
				currCarpetPolarity = ChargableUtils.CHARGE_NONE;
				return true;
			case GROUND_SENSOR_ID:
				if (b.GetUserData() == FOOT_SENSOR_ID || b.GetUserData() == PLAYER_BODY_ID){
					numGroundContacts--;
					return true;
				}
				break;
			default:
				return false;
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
