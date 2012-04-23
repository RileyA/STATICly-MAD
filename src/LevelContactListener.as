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
		
		public function LevelContactListener() {
			actionCandidates = new Vector.<GfxPhysObject>();
		}
		
		public function getBestAction():GfxPhysObject {
			actionCandidates.sort(compare);
		}
		
		public override function BeginContact(contact:b2Contact):void {
			var elementA:GfxPhysObject = contact.GetFixtureA().GetUserData();
			var elementB:GfxPhysObject = contact.GetFixtureB().GetUserData();
			if (elementA == Player || elementB == Player) {
				if (elementA != Player) {
					actionCandidates.push(elementA);
				} else if (elementB != Player) {
					actionCandidates.push(elementB);
				}
			}
		}
		
		public override function EndContact(contact:b2Contact):void {
			var elementA = contact.GetFixtureA().GetUserData();
			var elementB = contact.GetFixtureB().GetUserData();
			if (elementA == Player || elementB == Player) {
				if (elementA != Player) {
					holder = elementA;
				} else if (elementB != Player) {
					holder = elementB;
				}
				actionCandidates = actionCandidates.filter(removeFunc);
			}
			
		}
		
		private function removeFunc(item:GfxPhysObject):Boolean {
			return item != holder;
		}
		
		private function compare(x:GfxPhysObject, y:GfxPhysObject):Number {
			
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