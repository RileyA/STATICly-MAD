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
			m_level = new Level(this, MiscUtils.loadLevelInfo("Overworld"));
		}
		
		override public function deinit():void {
			m_level = null;
		}

		/**
		* Returns false if this LevelState has reached a termination state.
		*/
		override public function update(delta:Number):Boolean {
			var isDone:Boolean = false;
			var levelEnter:Boolean = !m_level.update(delta);
			if (levelEnter) {
				enterLevel(m_level.getNextLevel());
				m_level.resetLevel();
			}
			isDone ||= Keys.isKeyPressed(Keyboard.ESCAPE);
			return !isDone;
		}

		/**
		* Enter the specified level
		*/
		private function enterLevel(name:String):void {
			if (name == null){ return; }
			//else if (name == overworld level) {
			//	m_game.addState(new OverworldState(m_game, name));
			//} else {
			m_game.addState(new LevelState(m_game, name));
		}
	}
}
