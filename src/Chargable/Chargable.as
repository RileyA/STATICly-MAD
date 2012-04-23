package Chargable {
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
