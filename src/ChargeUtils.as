package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;

	/**
	* Utility constants and functions relating to electrostatics.
	*/
	public class ChargeUtils {
		public static const charge_blue:int = -1;
		public static const charge_none:int = 0;
		public static const charge_red:int = +1;

		/** Applies the electrostatic force of the specified from Chargable
		* to the specified onto Chargable.
		*/
		public static function applyChargeForce(from:Chargable, onto:Chargable):void{
			var ontoBody:b2Body = onto.getBody();
			var fromBody:b2Body = from.getBody();
			var vec:b2Vec2 = ontoBody.GetWorldCenter();
			vec=new b2Vec2(vec.x,vec.y);
			vec.Subtract(fromBody.GetWorldCenter());
			var s:Number=from.getCharge()*onto.getCharge()*(1.0/vec.LengthSquared());
			s=s*200.0;
			vec.Multiply(s/vec.Length());
			ontoBody.ApplyForce(vec,ontoBody.GetWorldCenter());
		}
	

	/**
	* Defines an object that is chargable with electricty and particpates in
	* the electrostatics physics engine.
	*/
	public interface Chargable {

		/**
		* Returns the charge of this Chargable for electrostatics computations.
		*/
		function getCharge():Number;

		/**
		* Returns the b2Body of this Chargable for physics operations.
		*/
		function getBody():b2Body;
	}
}

