package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class Block{
		public static const charge_blue:int = -1;
		public static const charge_none:int = 0;
		public static const charge_red:int = +1;
		
		private static const strongChargeDensity:Number = 2.5; // charge per square m
		private static const weakChargeDensity:Number = 1.0; // charge per square m
		
		private static const strongDensity:Number = 10.0; // kg per square m
		private static const weakDensity:Number = 10.0; // kg per square m
		
		public var body:b2Body;
		private var charge:int;
		private var strong:Boolean;
		
		private var chargeStrength:Number;
		
		// A handy helper for making rectangle blocks
		public static function MakeRect(bm:BlockManager,
				topLeft:b2Vec2,
				bottomRight:b2Vec2,
				charge:int,
				dynamicBody:Boolean,
				strong:Boolean,
				insulated:Boolean):Block{
			var polyShape:b2PolygonShape = new b2PolygonShape();
			
			var position:b2Vec2 = topLeft.Copy();
			position.Add(bottomRight);
			position.Multiply(0.5);
			
			var w:Number=bottomRight.x-topLeft.x;
			var h:Number=bottomRight.y-topLeft.y;
			
			polyShape.SetAsBox(w/2,h/2);
			
			return new Block(bm,position,polyShape,charge,dynamicBody,strong,insulated);
		}
		
		public function Block(bm:BlockManager,
				position:b2Vec2,
				polyShape:b2PolygonShape,
				charge:int,
				dynamicBody:Boolean,
				strong:Boolean,
				insulated:Boolean
				):void{
			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = dynamicBody?b2Body.b2_dynamicBody:b2Body.b2_staticBody;		
			
			this.strong=strong;
			this.charge=charge;
			
			fd.shape = polyShape;
			fd.density =strong?strongDensity:weakDensity;
			fd.friction = 0.3;
			fd.restitution = 0.1;
			rectDef.position.Set(position.x,position.y);
			rectDef.angle = 0.0;
			body = bm.world.CreateBody(rectDef);
			body.CreateFixture(fd);
			
			//body.SetFixedRotation(true);
			body.SetLinearDamping(1.0);
			body.SetAngularDamping(1.0);
			
			var area:Number=body.GetMass()/fd.density;
			
			this.chargeStrength=area*(strong?strongChargeDensity:weakChargeDensity);
			
			
			bm.addBlock(this);
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
		
	}
}
