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
		private var bodyWidth:Number;
		private var bodyHeight:Number;
		private var surfaces:Vector.<SurfaceElement>;
		private var actions:Vector.<ActionElement>;
		private var sprite:Sprite;
		
		/**
		 * For specifying by position and size
		 * @param	blockInfo
		 * @param	world
		 */
		public function Block(blockInfo:BlockInfo, world:b2World):void {
			var pos:b2Vec2 = blockInfo.pixels ? new b2Vec2(
				blockInfo.x / PhysicsUtils.PIXELS_PER_METER, 
				blockInfo.y / PhysicsUtils.PIXELS_PER_METER)
				: new b2Vec2(blockInfo.x, blockInfo.y);

			bodyWidth = blockInfo.pixels ? blockInfo.width
				/ PhysicsUtils.PIXELS_PER_METER : blockInfo.width;
			bodyHeight = blockInfo.pixels ? blockInfo.height
				/ PhysicsUtils.PIXELS_PER_METER : blockInfo.height;

			// if in pixels offset for upper-left origin
			if(blockInfo.pixels) {
				pos.x += bodyWidth / 2;
				pos.y += bodyHeight / 2;
			}

			movement = blockInfo.movement;

			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(bodyWidth / 2, bodyHeight / 2);

			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED 
				? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			rectDef.position.Set(pos.x, pos.y);
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
			sprite.graphics.beginFill(movement == FIXED ? 0x999999 : 
				0x333333);
			if(blockInfo.pixels)
				sprite.graphics.drawRect(-blockInfo.width/2, -blockInfo.height/2, 
					blockInfo.width, blockInfo.height);
			else
				sprite.graphics.drawRect(
					0,
					0,
					blockInfo.width * PhysicsUtils.PIXELS_PER_METER,	
					blockInfo.height * PhysicsUtils.PIXELS_PER_METER
				);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		private function addSurface(key:String, world:b2World):void {
			var pos:b2Vec2 = m_physics.GetPosition();
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			if (dir == UP) {
				pos.Set(pos.x, pos.y - bodyHeight);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, bodyWidth * 2, 4, world));
			}else if (dir == DOWN) {
				pos.Set(pos.x, pos.y + bodyHeight);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, bodyWidth * 2, 4, world));
			}else if (dir == LEFT) {
				pos.Set(pos.x - bodyWidth, pos.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, 4, bodyHeight * 2, world));
			}else if (dir == RIGHT) {
				pos.Set(pos.x + bodyWidth, pos.y);
				surfaces.push(SurfaceElement.getRelatedType(type, pos, 4, bodyHeight * 2, world));
			}
		}
		
		private function addAction(key:String, world:b2World):void {
			
		}
	}
}
