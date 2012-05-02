package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Contacts.*;
	import flash.display.*;
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ActionIndicator extends GfxPhysObject {
		
		private var player:Player;
		private var target:b2Body;
		
		private static const SPEED:Number = 1;
		private static const LENGTH:Number = .1;
		
		public function ActionIndicator(player:Player, target:b2Body, world:b2World):void {
			
			var fd:b2FixtureDef = new b2FixtureDef();
			var ccDef:b2BodyDef = new b2BodyDef();
			ccDef.type = b2Body.b2_dynamicBody;
			ccDef.allowSleep = false;
			ccDef.position = player.getPhysics().GetPosition();
			fd.isSensor = true;
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsBox(LENGTH, LENGTH);
			fd.shape = shape;
			m_physics = world.CreateBody(ccDef);
			m_physics.CreateFixture(fd);
			m_physics.SetFixedRotation(true);
			
			this.player = player;
			this.target = target;
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.lineStyle(1.0,0xFFFFFF,1.0,false,LineScaleMode.NONE);
			sprite.graphics.beginFill(0xBBBBBB);
			sprite.graphics.drawRect(0, 0, .2, .2);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		public function update():void {
			
		}
		
	}

}