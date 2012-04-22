package 
{
	
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ChargedBlock extends Block implements Chargeable {
		
		public static const charge_blue:int = -1;
		public static const charge_none:int = 0;
		public static const charge_red:int = +1;
		
		private static const strongChargeDensity:Number = 2.5; // charge per square m
		private static const weakChargeDensity:Number = 1.0; // charge per square m
		
		private static const strongDensity:Number = 10.0; // kg per square m
		private static const weakDensity:Number = 10.0; // kg per square m
		
		private var charge:int;
		private var strong:Boolean;
		private var insulated:Boolean;
		
		private var chargeStrength:Number;
		
		public function ChargedBlock(position:b2Vec2,
				polyShape:b2PolygonShape,
				charge:int,
				movement:String,
				strong:Boolean,
				insulated:Boolean):void {
			super(position, polyShape, movement);
			
			var area:Number=body.GetMass()/fd.density;
			
			this.strong=strong;
			this.charge = charge;
			this.insulated = insulated;
			this.chargeStrength=area*(strong?strongChargeDensity:weakChargeDensity);
			
		}
		
		private function getCharge():Number{
			return charge*chargeStrength;
		}
		
		// Sets the force from other on this
		public function DoChargeForce(other:Block):void{
			var vec:b2Vec2 = body.GetWorldCenter();
			vec=new b2Vec2(vec.x,vec.y);
			vec.Subtract(other.body.GetWorldCenter());
			var s:Number=other.getCharge()*getCharge()*(1.0/vec.LengthSquared());
			s=s*200.0;
			vec.Multiply(s/vec.Length());
			body.ApplyForce(vec,body.GetWorldCenter());
		}
		
		/**
		 * To be used when the state of the block is done being changed and the graphics is 
		 * to be loaded*/
		override public function finalize():void {
			super.finalize();
		}
	}
	
}