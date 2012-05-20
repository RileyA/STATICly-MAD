package {
	import starling.display.Sprite;
	import starling.text.TextField;
	import Colors;

	public class Menu {
		public static const MENU_Y:int=5;
		public static const exitString:String="(Q) to exit";
		public static const resetString:String="(R) to reset";
		public static const timerString:String="Time: ";
		public static const parTimeString:String="Par Time: ";
		public static const scoreString:String="Score: ";

		public static const textScale:Number=1.1;
		public static const textSize:Number=14.0;
		public static const verticalSpacing:Number=18.0;

		private var exitText:TextField;
		private var resetText:TextField;
		private var titleText:TextField;
		private var timerText:TextField;
		private var parTimeText:TextField;
		private var scoreText:TextField;
		private var m_timerText:TextField;

		public function Menu():void {

			var width:int = exitString.length*textSize;
			exitText = new TextField(exitString.length*textSize, 2.5*textSize, exitString,"Sans",textSize,Colors.textColor);
			exitText.hAlign = "left";
			exitText.scaleX = textScale;
			exitText.scaleY = exitText.scaleX;
			exitText.x = 30;
			exitText.y = MENU_Y;

			width = resetString.length*textSize;
			resetText = new TextField(resetString.length*textSize, 2.5*textSize, resetString,"Sans",textSize,Colors.textColor);
			resetText.hAlign = "left";
			resetText.scaleX = textScale;
			resetText.scaleY = resetText.scaleX;
			resetText.x = 30;
			resetText.y = MENU_Y+verticalSpacing;

			titleText = new TextField(200, 2.5*textSize*1.5, "","Sans",textSize*1.5,Colors.textColor);
			titleText.hAlign = "center";
			titleText.scaleX = textScale;
			titleText.scaleY = titleText.scaleX;
			titleText.x = 300;
			titleText.y = MENU_Y;

			width = (timerString.length+10)*textSize;
			timerText = new TextField(width, 2.5*textSize, timerString+"0","Sans",textSize,Colors.textColor);
			timerText.hAlign = "left";
			timerText.scaleX = textScale;
			timerText.scaleY = timerText.scaleX;
			timerText.x = 500;
			timerText.y = MENU_Y;

			width = (parTimeString.length+10)*textSize;
			parTimeText = new TextField(width, 2.5*textSize, parTimeString+"0","Sans",textSize,Colors.textColor);
			parTimeText.hAlign = "left";
			parTimeText.scaleX = textScale;
			parTimeText.scaleY = parTimeText.scaleX;
			parTimeText.x = 500;
			parTimeText.y = MENU_Y+verticalSpacing;

			width = (scoreString.length+10)*textSize;
			scoreText = new TextField(width, 2.5*textSize, scoreString+"0","Sans",textSize,Colors.textColor);
			scoreText.hAlign = "left";
			scoreText.scaleX = textScale;
			scoreText.scaleY = scoreText.scaleX;
			scoreText.x = 650;
			scoreText.y = MENU_Y;
		}

		public function attachTo(parent:Sprite):void {
			parent.addChild(exitText);
			parent.addChild(resetText);
			parent.addChild(titleText);
			parent.addChild(timerText);
			parent.addChild(parTimeText);
			parent.addChild(scoreText);
		}

		public function removeFrom(parent:Sprite):void {
			parent.removeChild(exitText);
			parent.removeChild(resetText);
			parent.removeChild(titleText);
			parent.removeChild(timerText);
			parent.removeChild(parTimeText);
			parent.removeChild(scoreText);
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

		public function updateOverworldInfo(name:String, score:int):void {
			titleText.text = name;
			scoreText.text = scoreString + MiscUtils.setPrecision(score, 0);
		}

		public function updateLevelInfo(info:ScoreInfo):void {
			timerText.text = timerString + MiscUtils.setPrecision(info.playerTime, 0);
			titleText.text = info.title;
			parTimeText.text = parTimeString + MiscUtils.setPrecision(info.targetTime, 0);
		}

		public function updateTime(time:Number):void {
			timerText.text = timerString + MiscUtils.setPrecision(time, 0);
		}
	}
}