package {
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFormat;
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

		private var m_player:Player;

		public function LevelState(game:Game):void {
			super(game);
		}

		override public function init():void {
			world = new b2World(GRAVITY, DO_SLEEP);
			world.SetWarmStarting(true);

			m_player = new Player(this);
			addChild(m_player);
			m_player.registerKeyListeners(stage);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			world.Step(TIMESTEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
			world.ClearForces();
			m_player.update();
			return true;
		}
	}
}
