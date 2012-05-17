package {
	import starling.text.TextField;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Colors;

	/** A basic level gameplay state */
	public class LevelState extends GameState {

		private var m_level:Level;
		private var m_levelName:String;
		private var m_timerText:TextField;
		private var m_overworldState:OverworldState;

		[Embed(source = "../media/images/TiledBackground.png")]
		private static const Background:Class;
		
		public function LevelState(game:Game, levelName:String, overworldState:OverworldState):void {
			super(game);
			m_levelName = levelName;
			m_overworldState=overworldState;

			tileBG(Background);
			
			m_timerText = new TextField(200, 50, "0","Sans",12,Colors.textColor);
			m_timerText.x = 10;
			m_timerText.y = 10;
			m_timerText.hAlign = "left";
		}
		
		override public function init():void {
			m_level = new Level(this, MiscUtils.loadLevelInfo(m_levelName));
			//addChild(m_timerText);
			var menu:Menu = m_game.getMenu();
			menu.setLevelMenu();
			menu.updateInfo(m_level.getScore());
			menu.attachTo(this);
			LoggerUtils.logLevelStart(m_levelName, null);
		}
		
		override public function deinit():void {
			m_level = null;
			//removeChild(m_timerText);
			m_game.getMenu().removeFrom(this);
		}

		/**
		* Returns false if this LevelState has reached a termination state.
		*/
		override public function update(delta:Number):Boolean {

			if (m_level != null){
				m_timerText.text = m_level.getInfo().title+": "+MiscUtils.setPrecision(m_level.getScore().playerTime, 0);
				m_game.getMenu().updateTime(m_level.getScore().playerTime);
			}
			
			var isDone:Boolean = false;
			var levelFinish:Boolean = !m_level.update(delta);
			if (levelFinish) { finishLevel(); }
			if (Keys.exitLevel()) {
				LoggerUtils.logLevelEnd({"didwin":false});
				isDone = true;
			}
			return !isDone;
		}

		private function finishLevel():void {
			m_overworldState.completed(m_levelName);
			LoggerUtils.logLevelEnd({"didwin":true});
			m_game.replaceState(new ScoreState(m_game, m_level.getScore()));
		}
	}
}
