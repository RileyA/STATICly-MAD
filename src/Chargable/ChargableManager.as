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
			var vec:b2Vec2 = ontoBody.GetWorldCenter();
			vec=new b2Vec2(vec.x,vec.y);
			vec.Subtract(fromBody.GetWorldCenter());
			var s:Number=from.getCharge()*onto.getCharge()*(1.0/vec.LengthSquared());
			s=s*200.0;
			vec.Multiply(s/vec.Length());
			ontoBody.ApplyForce(vec,ontoBody.GetWorldCenter());
		}
	}

}

