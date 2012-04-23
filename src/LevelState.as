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

		private static const TIMESTEP:Number = 0.033333;
		private static const POSITION_ITERATIONS:uint = 4;
		private static const VELOCITY_ITERATIONS:uint = 6;
		private static const DO_SLEEP:Boolean = true;
		private static const GRAVITY:b2Vec2 = new b2Vec2(0.0,9.8);

		// Debug controls:
		private static const TOGGLE_DEBUG_DRAW_KEY:Number = Keyboard.D;

		private var m_debugDraw:Boolean;
		private var m_debugDrawKey:Boolean;
		private var m_debugSprite:Sprite;
		private var m_player:Player;
		private var m_walls:Vector.<Block>;

		public function LevelState(game:Game):void {
			super(game);
			m_debugDraw = false;
		}

		override public function init():void {
			world = new b2World(GRAVITY, DO_SLEEP);
			world.SetWarmStarting(true);

			m_player = new Player(this);
			addChild(m_player);
			m_player.registerKeyListeners(stage);
			m_walls = new Vector.<Block>;

			prepareWalls();
			prepareDebugVisualization();
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			world.Step(TIMESTEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
			world.ClearForces();
			m_player.update();

			if (isKeyPressed(TOGGLE_DEBUG_DRAW_KEY) && !m_debugDrawKey) {
				m_debugDrawKey = true;
				m_debugDraw = !m_debugDraw;
				m_debugSprite.visible = m_debugDraw;
			} else if (!isKeyPressed(Keyboard.D) && m_debugDrawKey) {
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
			debugDraw.SetDrawScale(GfxPhysObject.PIXELS_PER_METER);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(debugDraw);
		}

		private function prepareWalls():void {

			var shapeWidth:Number = 800 / PhysicsUtils.PIXELS_PER_METER;
			var shapeHeight:Number = 100 / PhysicsUtils.PIXELS_PER_METER;
			var empty:BlockInfo = new BlockInfo(new Vector.<String>, 
				new Vector.<String>);

			// top
			m_walls.push(new Block(PhysicsUtils.fromPixels(new b2Vec2(0,-100)), 
				shapeWidth, shapeHeight, Block.FIXED, empty, world));

			// bottom
			m_walls.push(new Block(PhysicsUtils.fromPixels(new b2Vec2(0,700)), 
				shapeWidth, shapeHeight, Block.FIXED, empty, world));

			shapeWidth = 100 / PhysicsUtils.PIXELS_PER_METER;
			shapeHeight = 600 / PhysicsUtils.PIXELS_PER_METER;
			
			// left
			m_walls.push(new Block(PhysicsUtils.fromPixels(new b2Vec2(-100, 0.0)), 
				shapeWidth, shapeHeight, Block.FIXED, empty, world));

			// right
			m_walls.push(new Block(PhysicsUtils.fromPixels(new b2Vec2(900, 0.0)),
				shapeWidth, shapeHeight, Block.FIXED, empty, world));
		}
	}
}
