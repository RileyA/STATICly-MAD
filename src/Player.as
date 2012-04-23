package {

	import GfxPhysObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	public class Player extends GfxPhysObject {

		private var m_characterController:CharacterController;
		private var m_moveLeftKey:Boolean;
		private var m_moveRightKey:Boolean;
		private var m_jumpKey:Boolean;
		private var m_sprite:Sprite;

		private static const LEFT_KEY:Number = Keyboard.LEFT;
		private static const RIGHT_KEY:Number = Keyboard.RIGHT;
		private static const JUMP_KEY:Number = Keyboard.UP;
		private static const ACTION_KEY:Number = Keyboard.DOWN;

		public function Player(levelState:LevelState):void {
			m_sprite = new Sprite();
			m_sprite.graphics.beginFill(0xff0000);
			m_sprite.graphics.drawRect(0,0,50,50);
			m_sprite.graphics.endFill();
			addChild(m_sprite);
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			var w:Number=.7;
			var h:Number=-1.2;
			var hMid:Number=-0.9;
			polyShape.SetAsArray([new b2Vec2(0,h),new b2Vec2(w/2,hMid),
				new b2Vec2(w/2,0),new b2Vec2(-w/2,0),new b2Vec2(-w/2,hMid)])

			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = b2Body.b2_dynamicBody;
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			m_physics = levelState.world.CreateBody(rectDef);
			m_physics.CreateFixture(fd);
			rectDef.position.Set(0, 0);
			rectDef.angle = 0.0;

			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);

			m_characterController = new CharacterController(levelState, m_physics);
		}

		public function handleKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode == LEFT_KEY)
				m_moveLeftKey = true;
			else if (evt.keyCode == RIGHT_KEY)
				m_moveRightKey = true;
			else if (evt.keyCode == JUMP_KEY)
				m_jumpKey = true;
		}

		public function handleKeyUp(evt:KeyboardEvent):void {
			if (evt.keyCode == LEFT_KEY)
				m_moveLeftKey = false;
			else if (evt.keyCode == RIGHT_KEY)
				m_moveRightKey = false;
			else if (evt.keyCode == JUMP_KEY)
				m_jumpKey = false;
		}

		public function registerKeyListeners(parent:DisplayObjectContainer):void {
			parent.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			parent.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}

		public function update():void {
			updateTransform();
			m_characterController.updateControls(m_moveLeftKey, 
				m_moveRightKey, m_jumpKey);
		}
	}
}
