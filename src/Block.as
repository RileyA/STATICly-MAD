package {
	import flash.display.Sprite;
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
		private var scale:UVec2;
		private var surfaces:Vector.<SurfaceElement>;
		private var actions:Vector.<ActionElement>;
		private var sprite:Sprite;
		
		/**
		 * @param	blockInfo
		 * @param	world
		 */
		public function Block(blockInfo:BlockInfo, world:b2World):void {

			var position:UVec2 = blockInfo.position.getCopy();
			scale = blockInfo.scale.getCopy();
			movement = blockInfo.movement;

			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(scale.x / 2, scale.y / 2);

			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED 
				? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			rectDef.position.Set(position.x, position.y);
			rectDef.angle = 0.0;
			m_physics = world.CreateBody(rectDef);

			var fd:b2FixtureDef = new b2FixtureDef();
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			m_physics.CreateFixture(fd);
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);

			var i:int = 0;

			for (i = 0; i < blockInfo.surfaces.length; i++) {
				addSurface(blockInfo.surfaces[i], world);
			}
			for (i = 0; i < blockInfo.actions.length; i++) {
				addAction(blockInfo.actions[i], world);
			}

			sprite = new Sprite();
			sprite.graphics.beginFill(movement == FIXED ? 0x999999 : 0x333333);
			sprite.graphics.drawRect(-scale.x / 2, -scale.y / 2, scale.x, scale.y);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		private function addSurface(key:String, world:b2World):void {
			var pos:b2Vec2 = m_physics.GetPosition();
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			if (dir == UP) {
				pos.Set(pos.x, pos.y - scale.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, scale.x * 2, 4, world));
			}else if (dir == DOWN) {
				pos.Set(pos.x, pos.y + scale.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, scale.x * 2, 4, world));
			}else if (dir == LEFT) {
				pos.Set(pos.x - scale.x, pos.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, 4, scale.y * 2, world));
			}else if (dir == RIGHT) {
				pos.Set(pos.x + scale.x, pos.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, 4, scale.y * 2, world));
			}
		}
		
		private function addAction(key:String, world:b2World):void {
			
		}
	}
}
