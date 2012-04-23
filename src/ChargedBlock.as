package 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ChargedBlock extends Block implements Chargable {
		
		private static const strongChargeDensity:Number = 2.5; // charge per square m
		private static const weakChargeDensity:Number = 1.0; // charge per square m
		
		private static const strongDensity:Number = 10.0; // kg per square m
		private static const weakDensity:Number = 10.0; // kg per square m
		
		private var charge:int;
		private var strong:Boolean;
		private var insulated:Boolean;
		
		private var chargeStrength:Number;
		
		public function ChargedBlock(position:b2Vec2,
				hx:Number,
				hy:Number,
				charge:int,
				movement:String,
				strong:Boolean,
				insulated:Boolean,
				blockInfo:BlockInfo,
				world:b2World):void {
			super(position, hx, hy, movement, blockInfo, world);
			init(charge, strong, insulated);
		}
		
		public function ChargedBlock(topLeft:b2Vec2,
				bottomRight:b2Vec2,
				charge:int,
				movement:String,
				strong:Boolean,
				insulated:Boolean,
				blockInfo:BlockInfo,
				world:b2World):void {
			super(topLeft, bottomRight, movement, blockInfo, world);
			init(charge, strong, insulated);
		}
		
		private function init(charge:int, strong:Boolean, insulated:Boolean):void {
			var area:Number=body.GetMass()/fd.density;
			this.strong=strong;
			this.charge = charge;
			this.insulated = insulated;
			this.chargeStrength=area*(strong?strongChargeDensity:weakChargeDensity);
		}
		
		/**
		* Returns the charge of this Chargable for electrostatics computations.
		*/
		public function getCharge():Number{
			return charge*chargeStrength;
		}

		/**
		* Returns the b2Body of this Chargable for physics operations.
		*/
		public function getBody():b2Body{
			return body;
		}
		
		/**
		 * To be used when the state of the block is done being changed and the graphics is 
		 * to be loaded*/
		override public function finalize():void {
			super.finalize();
		}
	}
	
}
