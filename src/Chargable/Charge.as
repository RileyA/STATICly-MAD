package Chargable {
	import Box2D.Common.Math.b2Vec2;
	public class Charge {
		public var strength:Number;
		public var loc:b2Vec2;
		
		public function Charge(strength:Number,loc:b2Vec2):void {
			this.strength=strength;
			this.loc=loc;
		}
	}
}
