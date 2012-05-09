package {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import Editor.*;

	/** Simple placeholder menu state with a button that starts another state */
	public class ScoreState extends GameState {

		private var m_score:ScoreInfo;

		public function ScoreState(game:Game, m_score:ScoreInfo):void {
			super(game);
			this.m_score = m_score;
		}

		override public function init():void {
			var format:TextFormat = new TextFormat("Sans", 30, 0xBBBBBB);

			format.align = "center";
			var hello_text:TextField = new TextField();
			hello_text.width = 800;
			hello_text.height = 100;
			hello_text.x = 0;
			hello_text.y = 150;
			hello_text.defaultTextFormat = format;
			hello_text.text = "Level Cleared!";
			hello_text.selectable = false;
			addChild(hello_text);

			format.align = "left";
			var player_time_text:TextField = new TextField();
			player_time_text.width = 600;
			player_time_text.height = 50;
			player_time_text.x = 100;
			player_time_text.y = 250;
			player_time_text.defaultTextFormat = format;
			player_time_text.text = "Your time:\t" + MiscUtils.setPrecision(m_score.playerTime, 1) +"s";
			player_time_text.selectable = false;
			addChild(player_time_text);

			format.align = "left";
			var par_time_text:TextField = new TextField();
			par_time_text.width = 600;
			par_time_text.height = 50;
			par_time_text.x = 100;
			par_time_text.y = 300;
			par_time_text.defaultTextFormat = format;
			par_time_text.text = "Target time:\t" + MiscUtils.setPrecision(m_score.targetTime, 0) +"s";
			par_time_text.selectable = false;
			addChild(par_time_text);

			format.align = "center";
			var editor_text:TextField = new TextField();
			editor_text.width = 600;
			editor_text.height = 50;
			editor_text.x = 100;
			editor_text.y = 400;
			editor_text.defaultTextFormat = format;
			editor_text.text = "Press (UP) to continue!";
			editor_text.selectable = false;
			addChild(editor_text);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			return !Keys.isKeyPressed(Keyboard.UP);
		}
	}
}
