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

	/** A basic level gameplay state */
	public class LevelState extends GameState {

		private var m_level:Level;

		public function LevelState(game:Game):void {
			super(game);
		}

		override public function init():void {
			m_level = new Level(this);
		}
		
		override public function deinit():void {
			m_level = null;
		}

		/**
		* Returns false if this LevelState has reached a termination state.
		*/
		override public function update(delta:Number):Boolean {
			var isDone:Boolean = false;
			var levelFinish:Boolean = !m_level.update(delta);
			if (levelFinish) { finishLevel(); }
			isDone ||= Keys.isKeyPressed(Keyboard.ESCAPE);
			return !isDone;
		}

		private function finishLevel():void {
			m_game.replaceState(new ScoreState(m_game, m_level.getScore()));
		}
	}
}
