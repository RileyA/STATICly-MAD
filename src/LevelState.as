package {
	import starling.text.TextField;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Colors;

	/** A basic level gameplay state */
	public class LevelState extends GameState {

		private var m_level:Level;
		private var m_levelName:String;
		private var m_didWin:Boolean;
		private var m_overworldState:OverworldState;

		[Embed(source = "../media/images/TiledBackground.png")]
		private static const Background:Class;
		
		public function LevelState(game:Game, levelName:String, overworldState:OverworldState):void {
			super(game);
			m_levelName = levelName;
			m_didWin = false;
			m_overworldState=overworldState;

			tileBG(Background);
		}
		
		override public function init():void {
			m_level = new Level(this, MiscUtils.loadLevelInfo(m_levelName));
			var menu:Menu = m_game.getMenu();
			menu.setLevelMenu();
			menu.updateLevelInfo(m_level.getScore());
			menu.attachTo(this);
			LoggerUtils.logLevelStart(m_levelName, null);
		}
		
		override public function deinit():void {
			LoggerUtils.logLevelEnd({"didwin":m_didWin});
			m_level = null;
			m_game.getMenu().removeFrom(this);
		}

		/**
		* Returns false if this LevelState has reached a termination state.
		*/
		override public function update(delta:Number):Boolean {

			if (m_level != null){
				m_game.getMenu().updateTime(m_level.getScore().playerTime);
			}
			
			var isDone:Boolean = false;
			var levelFinish:Boolean = !m_level.update(delta);
			if (levelFinish) { finishLevel(); }
			
			if (Keys.resetLevel()) {
				LoggerUtils.logResetLevel();
				m_game.replaceState(new LevelState(m_game, m_levelName, m_overworldState));
				
			}else if (Keys.exitLevel()) {
				LoggerUtils.logQuitLevel();
				m_game.terminate();
			}
			return !isDone;
		}

		private function finishLevel():void {
			m_didWin = true;
			var scoreState:ScoreState = new ScoreState(m_game, m_level.getScore());
			m_overworldState.completed(m_levelName, m_level.getScore().score);
			
			m_game.replaceState(scoreState);
		}
	}
}
