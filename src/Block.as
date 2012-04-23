package {
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Surfaces.*;

	public class Block extends GfxPhysObject{
		
		public static const FREE:String = "free";
		public static const TRACKED:String = "tracked";
		public static const FIXED:String = "fixed";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const BCARPET:String = "bcarpet";
		public static const RCARPET:String = "rcarpet";
		public static const GROUND:String = "ground";
		
		public static const flag_footSensor:int = 1;
		private var movement:String;
		private var final_flag:Boolean;
		
		private var surfaces:Vector.<SurfaceElement>;
		private var actions:Vector.<ActionElement>;
		
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
				movement:String,
				blockInfo:BlockInfo,
				world:b2World
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
			m_physics = world.CreateBody(rectDef);
			m_physics.CreateFixture(fd);
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);
			this.movement = movement;
			final_flag = false;
			
			var s:Dictionary = blockInfo.getSurfaces();
			
			
			//blockInfo.getSurfaces().forEach(addSurface);
			
		}
		
		private function addSurface(key:String, world:b2World):void {
			var pos:b2Vec2 = m_physics.GetPosition();
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			if (dir == UP) {
				
			}else if (dir == DOWN) {
				
			}else if (dir == LEFT) {
				
			}else if (dir == RIGHT) {
				
			}
			
		}
		
		private function addAction(dir:String, dist:Number, type:String, world:b2World):void {
			
			
		}
		
		/**
		 * To be used when the state of the block is done being changed and the graphics is 
		 * to be loaded*/
		private function finalize():void {
			
			final_flag = true;
		}
		
	}
}
