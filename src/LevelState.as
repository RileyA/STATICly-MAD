package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;

	/** A basic level gameplay state */
	public class LevelState extends GameState {

		private var m_level:Level;
		private var m_timerText:TextField;

		public function LevelState(game:Game):void {
			super(game);

			var format:TextFormat = new TextFormat("Sans", 15, 0x000000);
			format.align = "left";
			m_timerText = new TextField();
			m_timerText.width = 50;
			m_timerText.height = 50;
			m_timerText.x = 10;
			m_timerText.y = 10;
			m_timerText.defaultTextFormat = format;
			m_timerText.text = "0";
			m_timerText.selectable = false;
			addChild(m_timerText);
		}

		override public function init():void {
			m_level = new Level(this);
		}
		
		override public function deinit():void {
			m_level = null;
			removeChild(m_timerText);
		}

		/**
		* Returns false if this LevelState has reached a termination state.
		*/
		override public function update(delta:Number):Boolean {
			if (m_level != null)
				m_timerText.text = ""+MiscUtils.setPrecision(m_level.getScore().playerTime, 0);

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
