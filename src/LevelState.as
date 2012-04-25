package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Player;

	/** A basic level */
	public class LevelState extends GameState {

		public var world:b2World;
		public var contactListener:LevelContactListener;

		private static const TIMESTEP:Number = 0.033333;
		private static const POSITION_ITERATIONS:uint = 4;
		private static const VELOCITY_ITERATIONS:uint = 6;
		private static const DO_SLEEP:Boolean = true;

		[Embed(source="../media/levels/test_level_01.json",  mimeType=
			"application/octet-stream")] private const test_level_01:Class;

		// Debug controls:
		private static const TOGGLE_DEBUG_DRAW_KEY:Number = Keyboard.D;

		private var m_debugDraw:Boolean;
		private var m_debugDrawKey:Boolean;
		private var m_debugSprite:Sprite;
		private var m_player:Player;
		private var m_gfxPhysObject:Vector.<GfxPhysObject>;
		private var m_info:LevelInfo;

		public function LevelState(game:Game):void {
			super(game);
			m_debugDraw = false;
		}
		
		private function pixelsPerMeter():Number{
			return 30; // TODO Fix this riley
		}
		
		override public function init():void {

			m_gfxPhysObject = new Vector.<GfxPhysObject>;

			// load level JSON
			m_info = new LevelInfo();
			MiscUtils.loadJSON(new test_level_01() as ByteArray, m_info);

			world = new b2World(new b2Vec2(0.0, m_info.gravity), DO_SLEEP);
			world.SetWarmStarting(true);

			// add in all the blocks
			for (var i:uint = 0; i < m_info.blocks.length; ++i) {
				var loadedBlock:Block = new Block(m_info.blocks[i], world);
				addChild(loadedBlock);
				m_gfxPhysObject.push(loadedBlock);
			}

			m_player = new Player(this, PhysicsUtils.fromPixels(
				new b2Vec2(m_info.player_x, m_info.player_y)));
			addChild(m_player);
			m_gfxPhysObject.push(m_player);
			
			contactListener = new LevelContactListener();
			world.SetContactListener(contactListener);

			prepareDebugVisualization();

			var block_text:TextField = new TextField();
			block_text.width = 600;
			block_text.height = 500;
			block_text.x = 5;
			block_text.y = 5;
			block_text.text = "Testing Level: " + m_info.title;
			block_text.selectable = false;
			addChild(block_text);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			world.Step(TIMESTEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
			world.ClearForces();
			m_player.update(this);

			for (var i:uint = 0; i < m_gfxPhysObject.length; ++i)
				m_gfxPhysObject[i].updateTransform();

			if (isKeyPressed(TOGGLE_DEBUG_DRAW_KEY) && !m_debugDrawKey) {
				m_debugDrawKey = true;
				m_debugDraw = !m_debugDraw;
				m_debugSprite.visible = m_debugDraw;
			} else if (!isKeyPressed(TOGGLE_DEBUG_DRAW_KEY) && m_debugDrawKey) {
				m_debugDrawKey = false;
			}

			if (m_debugDraw)
				world.DrawDebugData();

			return true;
		}

		private function prepareDebugVisualization():void {
			m_debugSprite = new Sprite();
			addChild(m_debugSprite);
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(m_debugSprite);
			debugDraw.SetDrawScale(pixelsPerMeter());
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(debugDraw);
		}
	}
}
