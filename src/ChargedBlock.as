package 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Chargable.Chargable;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ChargedBlock extends Block implements Chargable {
		
		private static const strongChargeDensity:Number = 2.5; // charge per square m
		private static const weakChargeDensity:Number = 1.0; // charge per square m

		private static const strongDensity:Number = 10.0; // kg per square m
		private static const weakDensity:Number = 10.0; // kg per square m
		
		private var chargePolarity:int;
		private var strong:Boolean;
		private var insulated:Boolean;
		
		private var chargeStrength:Number;
		
		/**
		 * For specifying by position and size
		 * @param	position
		 * @param	hx
		 * @param	hy
		 * @param	chargePolarity
		 * @param	movement
		 * @param	strong
		 * @param	insulated
		 * @param	blockInfo
		 * @param	world
		 */
		public function ChargedBlock(position:b2Vec2,
				hx:Number,
				hy:Number,
				chargePolarity:int,
				movement:String,
				strong:Boolean,
				insulated:Boolean,
				blockInfo:BlockInfo,
				world:b2World):void {
			super(position, hx, hy, movement, blockInfo, world);
			init(chargePolarity, strong, insulated);
		}
		
		/**
		 * For specifying by the corners of the box
		 * @param	topLeft
		 * @param	bottomRight
		 * @param	chargePolarity
		 * @param	movement
		 * @param	strong
		 * @param	insulated
		 * @param	blockInfo
		 * @param	world
		 */
		public function ChargedBlock(topLeft:b2Vec2,
				bottomRight:b2Vec2,
				chargePolarity:int,
				movement:String,
				strong:Boolean,
				insulated:Boolean,
				blockInfo:BlockInfo,
				am:ActionMarker,
				world:b2World):void {
			super(topLeft, bottomRight, movement, blockInfo, world);
			var fd:b2FixtureDef = new b2FixtureDef();
			fd.userData = am;
			init(chargePolarity, strong, insulated);
		}
		
		private function init(chargePolarity:int, strong:Boolean, insulated:Boolean):void {
			var area:Number=body.GetMass()/fd.density;
			this.strong=strong;
			this.chargePolarity = chargePolarity;
			this.insulated = insulated;
			this.chargeStrength=area*(strong?strongChargeDensity:weakChargeDensity);
		}
		
		/**
		* Returns the charge of this Chargable for electrostatics computations.
		*/
		public function getCharge():Number{
			return chargePolarity*chargeStrength;
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
