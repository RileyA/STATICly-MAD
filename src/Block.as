package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class Block{
		public static const charge_blue:int = -1;
		public static const charge_none:int = 0;
		public static const charge_red:int = +1;
		
		public var body:b2Body;
		public var charge:int;
		public var strong:Boolean;
		
		
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
			fd.density = 1.0;
			fd.friction = 0.3;
			fd.restitution = 0.1;
			rectDef.position.Set(position.x,position.y);
			rectDef.angle = 0.0;
			body = bm.world.CreateBody(rectDef);
			body.CreateFixture(fd);
			
			//body.SetFixedRotation(true);
			body.SetLinearDamping(1.0);
			body.SetAngularDamping(1.0);
			
			bm.addBlock(this);
		}
	}
}
