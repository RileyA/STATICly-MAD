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
	import Chargable.Chargable;

	public class Player extends GfxPhysObject { //implements Chargable {

		private var m_characterController:CharacterController;
		private var m_moveLeftKey:Boolean;
		private var m_moveRightKey:Boolean;
		private var m_jumpKey:Boolean;
		private var m_actionKey:Boolean;
		private var m_sprite:Sprite;

		private static const LEFT_KEY:Number = Keyboard.LEFT;
		private static const RIGHT_KEY:Number = Keyboard.RIGHT;
		private static const JUMP_KEY:Number = Keyboard.UP;
		private static const ACTION_KEY:Number = Keyboard.DOWN;

		public function Player(levelState:LevelState):void {
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			var w:Number=.7;
			var h:Number=-1.2;
			var hMid:Number=-0.9;
			polyShape.SetAsArray([new b2Vec2(0,h),new b2Vec2(w/2,hMid),
				new b2Vec2(w/2,0),new b2Vec2(-w/2,0),new b2Vec2(-w/2,hMid)])

			var fd:b2FixtureDef = new b2FixtureDef();
			var ccDef:b2BodyDef = new b2BodyDef();
			ccDef.type = b2Body.b2_dynamicBody;
			ccDef.allowSleep = false;
			ccDef.awake = true;
			ccDef.position = new b2Vec2(400 / 30.0, 200 / 30.0);
			fd.shape = polyShape;
			fd.density = 10.0;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			fd.userData = "player";
			m_physics = levelState.world.CreateBody(ccDef);
			m_physics.CreateFixture(fd);
			m_physics.SetLinearDamping(.2);
			m_physics.SetAngularDamping(1.0);
			m_characterController = new CharacterController(levelState, m_physics);

			// placeholder sprite to be replaced with an animated MovieClip at some point...
			m_sprite = new Sprite();
			m_sprite.graphics.beginFill(0xff0000);
			m_sprite.graphics.drawRect(
				PhysicsUtils.PIXELS_PER_METER * -w/2.0,
				h * PhysicsUtils.PIXELS_PER_METER,
				w * PhysicsUtils.PIXELS_PER_METER,
				h * -PhysicsUtils.PIXELS_PER_METER);
			m_sprite.graphics.endFill();
			addChild(m_sprite);
		}

		public function handleKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode == LEFT_KEY)
				m_moveLeftKey = true;
			else if (evt.keyCode == RIGHT_KEY)
				m_moveRightKey = true;
			else if (evt.keyCode == JUMP_KEY)
				m_jumpKey = true;
			else if (evt.keyCode == ACTION_KEY)
				m_actionKey = true;
		}

		public function handleKeyUp(evt:KeyboardEvent):void {
			if (evt.keyCode == LEFT_KEY)
				m_moveLeftKey = false;
			else if (evt.keyCode == RIGHT_KEY)
				m_moveRightKey = false;
			else if (evt.keyCode == JUMP_KEY)
				m_jumpKey = false;
			else if (evt.keyCode == ACTION_KEY)
				m_actionKey = false;
		}

		public function registerKeyListeners(parent:DisplayObjectContainer):void {
			parent.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			parent.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}

		public function update(state:LevelState):void {
			updateTransform();
			m_characterController.updateControls(state,m_moveLeftKey, 
				m_moveRightKey, m_jumpKey);
		}
	}
}
