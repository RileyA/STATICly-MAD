package Chargable {
	import Box2D.Dynamics.*;

	/**
	* Defines an object that is chargable with electricty and particpates in
	* the electrostatics physics engine.
	*/
	public interface Chargable {

		/**
		* Returns the charge of this Chargable for electrostatics computations.
		*/
		// list of charges
		function getCharges():Vector.<Charge>;
		// scalar to multiply list entriesd by
		function getCharge():Number;
		/**
		* Returns the b2Body of this Chargable for physics operations.
		*/
		function getBody():b2Body;
	}
}
