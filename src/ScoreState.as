package {
	import starling.text.TextField;
	import flash.ui.Keyboard;
	import Editor.*;

	/** Simple placeholder menu state with a button that starts another state */
	public class ScoreState extends GameState {
		public static const COMPLETION_BONUS:int = 200;
		public static const TIME_FACTOR:int = 10;

		private var m_score:ScoreInfo;
		private var m_textFields:Vector.<TextField>;
		private var player_time:Number;
		private var under_par_time:Number;
		private var score:int;
		private var total:int;

		public function ScoreState(game:Game, m_score:ScoreInfo):void {
			super(game);
			this.m_score = m_score;
			this.m_textFields = new Vector.<TextField>();
			player_time = MiscUtils.setPrecision(m_score.playerTime, 0);
			under_par_time = MiscUtils.setPrecision(m_score.targetTime, 0) - player_time;
			under_par_time = Math.max(under_par_time, 0);
			score = under_par_time * TIME_FACTOR;
			total = score + COMPLETION_BONUS;

			m_score.score = total;
		}

		override public function init():void {
			m_game.getMenu().attachTo(this);

			var fontSize:int = 24;
			var fontColor:uint = 0xBBBBBB;
			var fontStyle:String = "Sans"
			
			var hello_text:TextField = new TextField(800, 100, 
				"Cleared!\n", fontStyle, fontSize*1.5, fontColor);
			hello_text.x = 0;
			hello_text.y = 100;
			hello_text.hAlign = "center"
			addChild(hello_text);
			m_textFields.push(hello_text);
			
			var player_column_text:TextField = new TextField(400, 400, 
				"Completion Bonus:\nYour Time:\nTime Under Par:\nTime Score:\n\nTotal Score:", 
				fontStyle, fontSize, fontColor);
			player_column_text.x = 150;
			player_column_text.y = 150;
			player_column_text.hAlign = "left";
			addChild(player_column_text);
			m_textFields.push(player_column_text);
			
			var score_column_text:TextField = new TextField(200, 400,
				COMPLETION_BONUS + "\n(" + player_time + ")s\n(" + under_par_time + ")s\n" + score + "\n\n" + total, 
				fontStyle, fontSize, fontColor);
			score_column_text.x = 400;
			score_column_text.y = 150;
			score_column_text.hAlign = "right";
			addChild(score_column_text);
			m_textFields.push(score_column_text);

			
			var editor_text:TextField = new TextField(600, 100, 
				"(ENTER) to Continue!\n", fontStyle, fontSize, fontColor);
			editor_text.x = 100;
			editor_text.y = 450;
			editor_text.hAlign = "center";
			addChild(editor_text);
			m_textFields.push(editor_text);

			// hackity hack..
			for (var i:uint = 0; i < m_textFields.length; ++i) {
				m_textFields[i].autoScale = true;
			}
		}

		override public function deinit():void {
			m_game.getMenu().removeFrom(this);

			for(var i:int = 0; i < m_textFields.length; i++) {
				removeChild(m_textFields[i]);
			}
		}

		override public function update(delta:Number):Boolean {
			return !Keys.isKeyPressed(Keyboard.ENTER);
		}
	}
}
