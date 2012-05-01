package {
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;

	/** A basic level gameplay state */
	public class OverworldState extends GameState {

		private var m_level:Level;

		public function OverworldState(game:Game):void {
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
			isDone ||= Keys.isKeyPressed(Keyboard.ESCAPE);
			return !isDone;
		}

	}
}
