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
			var stength:Number=from.getCharge()*onto.getCharge()*200.0;
			if (stength==0) {
				return;
			}
			var ontoBody:b2Body = onto.getBody();
			var fromBody:b2Body = from.getBody();
			var fc:Vector.<Charge>=from.getCharges();
			var oc:Vector.<Charge>=onto.getCharges();
			var fi:int;
			var oi:int;
			
			for (oi=0;oi<oc.length;oi++){
				var ontoLoc:b2Vec2=ontoBody.GetWorldPoint(oc[oi].loc);
				var ontoStr:Number=oc[oi].strength*stength;
				var force:b2Vec2=new b2Vec2(0,0);
				for (fi=0;fi<fc.length;fi++){
					// from location in world
					var vec:b2Vec2=fromBody.GetWorldPoint(fc[fi].loc);
					var totalStr:Number=fc[fi].strength*ontoStr;

					vec.Subtract(ontoLoc);
					var s:Number=totalStr/vec.LengthSquared();
					vec.Multiply(s/vec.Length());
					force.Subtract(vec);
				}
				ontoBody.ApplyForce(force,ontoLoc);
			}
		}
	
		public function getChargeForce(onto:Chargable):b2Vec2{
			// filter out the currently charged objects
			function hasCharge(c:Chargable,index:int= 0, blah:* = null):Boolean {
				return c.getCharge()!=0;
			}
			var vec:Vector.<Chargable>=chargables.filter(hasCharge);
			
			var force:b2Vec2=new b2Vec2(0,0);

				// if can move, apply forces to it:
			if (onto.getBody().GetType() == b2Body.b2_dynamicBody){
				// apply a force from all other Chargables 
				for (var j:int = 0; j<vec.length; j++){
					if (onto!=vec[j]){
						getChargeForceFrom(vec[j], onto, force);
					}
				}
			}
			return force;
		}

		/**
		* Applies the electrostatic force of the specified from Chargable
		* to the specified onto Chargable.
		*/
		private static function getChargeForceFrom(from:Chargable, onto:Chargable, force:b2Vec2):void{
			var stength:Number=from.getCharge()*onto.getCharge()*200.0;
			if (stength==0) {
				return;
			}
			var ontoBody:b2Body = onto.getBody();
			var fromBody:b2Body = from.getBody();
			var fc:Vector.<Charge>=from.getCharges();
			var oc:Vector.<Charge>=onto.getCharges();
			var fi:int;
			var oi:int;
			
			for (oi=0;oi<oc.length;oi++){
				var ontoLoc:b2Vec2=ontoBody.GetWorldPoint(oc[oi].loc);
				var ontoStr:Number=oc[oi].strength*stength;
				
				for (fi=0;fi<fc.length;fi++){
					// from location in world
					var vec:b2Vec2=fromBody.GetWorldPoint(fc[fi].loc);
					var totalStr:Number=fc[fi].strength*ontoStr;

					vec.Subtract(ontoLoc);
					var s:Number=totalStr/vec.LengthSquared();
					vec.Multiply(s/vec.Length());
					force.Subtract(vec);
				}
			}
		}
	}
}

