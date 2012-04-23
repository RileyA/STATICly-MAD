package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	* Keeps track of a set of Chargable objects and can apply electrostatic
	* forces between them.
	*/
	public class ChargableManager{

		// Defines the numeric charge value for blue, red, or no charge.
		public static const charge_blue:int = -1;
		public static const charge_none:int = 0;
		public static const charge_red:int = +1;

		private var bodies:Vector.<Chargable>;

		/**
		* Constructs a manager empty of objects.
		*/
		public function BlockManager():void{
			this.bodies=new Vector.<Chargable>();
		}

		/**
		* Adds a Chargable object to the elecrostatics simulation.
		*/
		public function addChargable(c:Chargable):void{
			bodies.push(c);
		}

		/**
		* Applies electrostatic force from all Chargable objects onto all
		*  Chargable objects that are dynamic (non static).
		*/
		public function applyChargeForces():void{
			for (var i:int = 0; i < bodies.length; i++){
				var from:Chargable = bodies[i];
				// Start at index i+1.  Guaranteed no repeat calculations.
				for (var j:int = i + 1; j<bodies.length; j++){
					var onto:Chargable = bodies[j];
					// Apply force only if the recieving body is not fixed.
					if (onto.getBody().GetType() == b2Body.b2_dynamicBody) {
						applyChargeForce(from, onto);
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

