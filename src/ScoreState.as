package {
	import starling.text.TextField;
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
			var fontSize:int = 30;
			var fontColor:uint = 0x000000;
			var fontStyle:String = "Sans"
			
			var hello_text:TextField = new TextField(800, 100, 
				"Level Cleared!", fontStyle, fontSize, fontColor);
			hello_text.x = 0;
			hello_text.y = 150;
			hello_text.hAlign = "center"
			addChild(hello_text);
			
			var player_time_text:TextField = new TextField(600, 50, 
				"Your time:\t" + MiscUtils.setPrecision(m_score.playerTime, 1) +"s", 
				fontStyle, fontSize, fontColor);
			player_time_text.x = 100;
			player_time_text.y = 250;
			player_time_text.hAlign = "left";
			addChild(player_time_text);
			
			var par_time_text:TextField = new TextField(600, 50, 
				"Target time:\t" + MiscUtils.setPrecision(m_score.targetTime, 0) +"s", 
				fontStyle, fontSize, fontColor);
			par_time_text.x = 100;
			par_time_text.y = 300;
			par_time_text.hAlign = "left";
			addChild(par_time_text);
			
			var editor_text:TextField = new TextField(600, 50, 
				"Press (UP) to continue!", fontStyle, fontSize, fontColor);
			editor_text.x = 100;
			editor_text.y = 400;
			editor_text.hAlign = "center";
			addChild(editor_text);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			return !Keys.isKeyPressed(Keyboard.UP);
		}
	}
}
