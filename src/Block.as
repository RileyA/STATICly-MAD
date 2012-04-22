package {
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class Block extends GfxPhysObject{
		
		public static const FREE:String = "free";
		public static const TRACKED:String = "tracked";
		public static const FIXED:String = "fixed";
		
		public static const flag_footSensor:int = 1;
		private var movement:String;
		private var final_flag:Boolean;
		
		// A handy helper for making rectangle blocks
		public static function MakeRect(topLeft:b2Vec2,
				bottomRight:b2Vec2,
				movement:String):Block{
			var polyShape:b2PolygonShape = new b2PolygonShape();
			
			var position:b2Vec2 = topLeft.Copy();
			position.Add(bottomRight);
			position.Multiply(0.5);
			
			var w:Number=bottomRight.x-topLeft.x;
			var h:Number=bottomRight.y-topLeft.y;
			
			polyShape.SetAsBox(w/2,h/2);
			
			return new Block(position,polyShape,movement);
		}
		
		public function Block(position:b2Vec2,
				polyShape:b2PolygonShape,
				movement:String
				):void {
			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED?b2Body.b2_dynamicBody:b2Body.b2_staticBody;		
			
			fd.shape = polyShape;
			fd.density =strong?strongDensity:weakDensity;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			rectDef.position.Set(position.x,position.y);
			rectDef.angle = 0.0;
			m_physics = bm.world.CreateBody(rectDef);
			m_physics.CreateFixture(fd);
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);
			this.movement = movement;
			final_flag = false;
			
		}
		
		/**
		 * To be used when the state of the block is done being changed and the graphics is 
		 * to be loaded*/
		public function finalize():void {
			
			final_flag = true;
		}
		
	}
}
