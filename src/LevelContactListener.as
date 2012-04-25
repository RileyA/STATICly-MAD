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
		

		
		public static const PLAYER_BODY_ID:int=1;
		public static const FOOT_SENSOR_ID:int=2;
		public static const JUMPABLE_ID:int=3;
		public static const GROUND_SENSOR_ID:int=4;
		public static const CARPET_POS_SENSOR_ID:int=5;
		public static const CARPET_NEG_SENSOR_ID:int=6;
		public static const PLAYER_ACTION_ID:int=7;
		
		public function LevelContactListener() {
			actionCandidates = new Vector.<GfxPhysObject>();
		}
		
		public function getBestAction(player:Player):GfxPhysObject {
			holder = player;
			actionCandidates.sort(compare);
			holder = null;
			return actionCandidates[0];
		}
		

		
		private function removeFunc(item:GfxPhysObject):Boolean {
			return item != holder;
		}
		
		private function compare(x:GfxPhysObject, y:GfxPhysObject):Number {
			return 7; // TODO make not stupid
		}
	}

}
