package Chargable {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	* Keeps track of a set of Chargable objects and can apply electrostatic
	* forces between them.
	*/
	public class ChargableManager{

		private var chargables:Vector.<Chargable>;

		/**
		* Constructs a manager empty of objects.
		*/
		public function ChargableManager():void{
			this.chargables=new Vector.<Chargable>();
		}

		/**
		* Adds a Chargable object to the elecrostatics simulation.
		*/
		public function addChargable(c:Chargable):void{
			chargables.push(c);
		}

		/** 
		* Removes a chargable object
		**/
		public function removeChargable(c:Chargable):void{
			for (var i:uint=0; i < chargables.length; ++i) {
				if (chargables[i] == c) {
					chargables[i] = chargables[chargables.length - 1];
					chargables.pop();
					break;
				}
			}
		}

		/**
		* Applies electrostatic force from all Chargable objects onto all
		*  Chargable objects that are dynamic (non static).
		*  Applying forces to static things does nothing, hence skipping them
		*/
		public function applyChargeForces():void{
			// filter out the currently charged objects
			function hasCharge(c:Chargable,index:int= 0, blah:* = null):Boolean {
				return c.getCharge()!=0;
			}
			var vec:Vector.<Chargable>=chargables.filter(hasCharge);
			
			// apply forces to them
			for (var i:int = 0; i < vec.length; i++){
				var onto:Chargable = vec[i];
				// if can move, apply forces to it:
				if (onto.getBody().GetType() == b2Body.b2_dynamicBody){
					// apply a force from all other Chargables 
					for (var j:int = 0; j<vec.length; j++){
						if (i!=j){
							applyChargeForce(vec[j], onto);
						}
					}
				}
			}
		}

		/**
		* Applies the electrostatic force of the specified from Chargable
		* to the specified onto Chargable.
		*/
		private static function applyChargeForce(from:Chargable, onto:Chargable):void{
			var ontoBody:b2Body = onto.getBody();
			var fromBody:b2Body = from.getBody();
			var fc:Vector.<Charge>=from.getCharges();
			var oc:Vector.<Charge>=onto.getCharges();
			var fi:int;
			var oi:int;
			var stength:Number=from.getCharge()*onto.getCharge()*200.0;
			for (fi=0;fi<fc.length;fi++){
				// from location in world
				var fromLoc:b2Vec2=fromBody.GetWorldPoint(fc[fi].loc);
				var fromStr:Number=fc[fi].strength*stength;
				for (oi=0;oi<oc.length;oi++){
					var ontoLoc:b2Vec2=ontoBody.GetWorldPoint(oc[oi].loc);
					var totalStr:Number=oc[oi].strength*fromStr;
					
					var vec:b2Vec2 = ontoLoc.Copy();
					vec.Subtract(fromLoc);
					var s:Number=totalStr*(1.0/vec.LengthSquared());
					vec.Multiply(s/vec.Length());
					ontoBody.ApplyForce(vec,ontoLoc);
				}
			}
		}
	}

}

