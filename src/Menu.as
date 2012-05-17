package {
	import starling.display.Sprite;
	import starling.text.TextField;
	import Colors;

	public class Menu extends Sprite {
		public static const MENU_Y:int=565;
		public static const exitString:String="Q to exit";
		public static const resetString:String="R to reset";
		public static const timerString:String="Time: ";
		public static const parTimeString:String="Par Time: ";
		public static const scoreString:String="Score: ";

		private var exitText:TextField;
		private var resetText:TextField;
		private var titleText:TextField;
		private var timerText:TextField;
		private var parTimeText:TextField;
		private var scoreText:TextField;

		public function Menu():void {
			var textScale:Number=.03;
			var textSize:Number=16.0;

			var width:int = exitString.length*textSize;
			exitText = new TextField(exitString.length*textSize, 2.5*textSize, exitString,"Sans",textSize,Colors.textColor);
			exitText.hAlign = "left";
			exitText.scaleX = textScale;
			exitText.scaleY = exitText.scaleX;
			exitText.x = 20;
			exitText.y = MENU_Y;
			addChild(exitText);

			width = resetString.length*textSize;
			resetText = new TextField(resetString.length*textSize, 2.5*textSize, resetString,"Sans",textSize,Colors.textColor);
			resetText.hAlign = "left";
			resetText.scaleX = textScale;
			resetText.scaleY = resetText.scaleX;
			resetText.x = 120;
			resetText.y = MENU_Y;
			addChild(resetText);

			titleText = new TextField(width, 2.5*textSize, "","Sans",textSize*1.5,Colors.textColor);
			titleText.hAlign = "center";
			titleText.scaleX = textScale;
			titleText.scaleY = titleText.scaleX;
			titleText.x = 250;
			titleText.y = MENU_Y;
			addChild(titleText);

			width = (timerString.length+10)*textSize;
			timerText = new TextField(width, 2.5*textSize, timerString+"0","Sans",textSize,Colors.textColor);
			timerText.hAlign = "left";
			timerText.scaleX = textScale;
			timerText.scaleY = timerText.scaleX;
			timerText.x = 400;
			timerText.y = MENU_Y;
			addChild(timerText);

			width = (parTimeString.length+10)*textSize;
			parTimeText = new TextField(width, 2.5*textSize, parTimeString+"0","Sans",textSize,Colors.textColor);
			parTimeText.hAlign = "left";
			parTimeText.scaleX = textScale;
			parTimeText.scaleY = parTimeText.scaleX;
			parTimeText.x = 500;
			parTimeText.y = MENU_Y;
			addChild(parTimeText);

			width = (scoreString.length+10)*textSize;
			scoreText = new TextField(width, 2.5*textSize, scoreString+"0","Sans",textSize,Colors.textColor);
			scoreText.hAlign = "left";
			scoreText.scaleX = textScale;
			scoreText.scaleY = scoreText.scaleX;
			scoreText.x = 700;
			scoreText.y = MENU_Y;
			addChild(scoreText);
		}

		public function setOverworldMenu():void {
			exitText.visible = false;
			resetText.visible = false;
			titleText.visible = true;
			timerText.visible = false;
			parTimeText.visible = false;
			scoreText.visible = true;
		}

		public function setLevelMenu():void {
			exitText.visible = true;
			resetText.visible = true;
			titleText.visible = true;
			timerText.visible = true;
			parTimeText.visible = true;
			scoreText.visible = true;
		}

		public function updateInfo(info:ScoreInfo):void {
			timerText.text = timerString + MiscUtils.setPrecision(info.playerTime, 0);
			titleText.text = info.title;
			parTimeText.text = parTimeString + MiscUtils.setPrecision(info.targetTime, 0);
			scoreText.text = scoreString + MiscUtils.setPrecision(info.score, 0);
		}

		public function updateTime(time:Number):void {
			timerText.text = timerString + MiscUtils.setPrecision(time, 0);
		}
	}
}
