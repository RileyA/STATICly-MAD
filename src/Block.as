package {
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Surfaces.*;
	import Actioners.*;

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
		
		private var movement:String;
		private var hx:Number;
		private var hy:Number;
		private var final_flag:Boolean;
		
		private var surfaces:Vector.<SurfaceElement>;
		private var actions:Vector.<ActionElement>;
		
		// A handy helper for making rectangle blocks
		/*public static function MakeRect(topLeft:b2Vec2,
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
		}*/
		
		/**
		 * For specifying by position and size
		 * @param	position
		 * @param	hx
		 * @param	hy
		 * @param	movement
		 * @param	blockInfo
		 * @param	world
		 */
		public function Block(position:b2Vec2,
				hx:Number,
				hy:Number,
				movement:String,
				blockInfo:BlockInfo,
				world:b2World
				):void {
			this.hx = hx;
			this.hy = hy;
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(hx, hy);
			init(position, polyShape, movement, blockInfo, world);
		}
		
		/**
		 * For specifying by the corners of the box
		 * @param	topLeft
		 * @param	bottomRight
		 * @param	movement
		 * @param	blockInfo
		 * @param	world
		 */
		/*public function Block(topLeft:b2Vec2,
				bottomRight:b2Vec2,
				movement:String,
				blockInfo:BlockInfo,
				world:b2World
				):void {		
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			var position:b2Vec2 = topLeft.Copy();
			position.Add(bottomRight);
			position.Multiply(0.5);
			hx = (bottomRight.x - topLeft.x) / 2;
			hy = (bottomRight.y - topLeft.y) / 2;			
			polyShape.SetAsBox(hx, hy);
			
			init(position, polyShape, movement, blockInfo, world);
		}*/
		
		private function init(position:b2Vec2,
				polyShape:b2PolygonShape,
				movement:String,
				blockInfo:BlockInfo,
				world:b2World): void {
			
			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED?b2Body.b2_dynamicBody:b2Body.b2_staticBody;
			fd.shape = polyShape;
			fd.density = 10.0;
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
			
			var i:int = 0;

			for (i = 0; i < blockInfo.getSurfaces().length; i++) {
				addSurface(blockInfo.getSurfaces()[i], world);
			}
			for (i = 0; i < blockInfo.getActions().length; i++) {
				addAction(blockInfo.getActions()[i], world);
			}
		}
		
		private function addSurface(key:String, world:b2World):void {
			var pos:b2Vec2 = m_physics.GetPosition();
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			if (dir == UP) {
				pos.Set(pos.x, pos.y - hy);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, hx * 2, 4, world));
			}else if (dir == DOWN) {
				pos.Set(pos.x, pos.y + hy);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, hx * 2, 4, world));
			}else if (dir == LEFT) {
				pos.Set(pos.x - hx, pos.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, 4, hy * 2, world));
			}else if (dir == RIGHT) {
				pos.Set(pos.x + hx, pos.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, 4, hy * 2, world));
			}
		}
		
		private function addAction(key:String, world:b2World):void {
			
			
		}
		
	}
}
