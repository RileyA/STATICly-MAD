package {
	import starling.display.Sprite;
	import starling.display.Quad;
	import starling.display.DisplayObjectContainer;
	import starling.text.TextField;
	import Colors;
	import MiscUtils;

	public class Menu extends DisplayObjectContainer {
		public static const MENU_Y:int=5;
		public static const exitString:String="(Q)uit\n";
		public static const resetString:String="(R)eset\n";
		public static const timerString:String="Time: ";
		public static const parTimeString:String="Par Time: ";
		public static const scoreString:String="Score: ";

		public static const textSize:Number=14;
		public static const verticalSpacing:Number=18.0;

		private var exitText:TextField;
		private var resetText:TextField;
		private var titleText:TextField;
		private var timerText:TextField;
		private var parTimeText:TextField;
		private var scoreText:TextField;

		public function Menu():void {

			var bgGradient:Quad = new Quad(800, 35, 0x000000);
			bgGradient.alpha = 0.75;
			addChild(bgGradient);
			bgGradient = new Quad(800, 65, 0x000000);
			bgGradient.y = 35;
			bgGradient.setVertexAlpha(0, 0.75);
			bgGradient.setVertexAlpha(1, 0.75);
			bgGradient.setVertexAlpha(2, 0.0);
			bgGradient.setVertexAlpha(3, 0.0);

			var width:int = exitString.length*textSize;
			exitText = new TextField(exitString.length*textSize, 2.5*textSize, exitString,"akashi",textSize,Colors.textColor);
			exitText.hAlign = "left";
			exitText.vAlign = "top";
			exitText.x = 30;
			exitText.y = MENU_Y;

			width = resetString.length*textSize;
			resetText = new TextField(resetString.length*textSize, 2.5*textSize, resetString,"akashi",textSize,Colors.textColor);
			resetText.hAlign = "left";
			resetText.vAlign = "top";
			resetText.x = 30;
			resetText.y = MENU_Y+verticalSpacing;

			titleText = new TextField(200, 2.5*textSize*1.5, "","akashi",textSize*1.5,Colors.textColor);
			titleText.hAlign = "center";
			titleText.vAlign = "top";
			titleText.x = 300;
			titleText.y = MENU_Y;

			width = (timerString.length+10)*textSize;
			timerText = new TextField(width, 2.5*textSize, timerString+"0","akashi",textSize,Colors.textColor);
			timerText.hAlign = "left";
			timerText.vAlign = "top";
			timerText.x = 130;
			timerText.y = MENU_Y+verticalSpacing;

			width = (parTimeString.length+10)*textSize;
			parTimeText = new TextField(width, 2.5*textSize, parTimeString+"0","akashi",textSize,Colors.textColor);
			parTimeText.hAlign = "left";
			parTimeText.vAlign = "top";
			parTimeText.x = 130;
			parTimeText.y = MENU_Y;

			width = (scoreString.length+10)*textSize;
			scoreText = new TextField(width, 2.5*textSize, scoreString+"0\n","akashi",textSize,Colors.textColor);
			scoreText.hAlign = "left";
			scoreText.vAlign = "top";
			scoreText.x = 600;
			scoreText.y = MENU_Y;

			// hackity hack
			exitText.autoScale = true;
			resetText.autoScale = true;
			titleText.autoScale = true;
			timerText.autoScale = true;
			parTimeText.autoScale = true;
			scoreText.autoScale = true;

			addChild(bgGradient);
			addChild(exitText);
			addChild(resetText);
			addChild(titleText);
			addChild(timerText);
			addChild(parTimeText);
			addChild(scoreText);
		}

		public function attachTo(parent_:Sprite):void {
			parent_.addChild(this);
			// make it always in same spot onscreen...
			x = -parent.x;
			y = -parent.y;
		}

		public function removeFrom(parent_:Sprite):void {
			parent_.removeChild(this);
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
			titleText.text = name + "\n";
			scoreText.text = scoreString + MiscUtils.setPrecision(score, 0) 
				+ "\n";
		}

		public function updateLevelInfo(info:ScoreInfo):void {
			timerText.text = timerString + MiscUtils.setPrecision(info.playerTime, 0);
			titleText.text = info.title + "\n";
			parTimeText.text = parTimeString + MiscUtils.setPrecision(info.targetTime, 0) + "\n";
		}

		public function updateTime(time:Number):void {
			timerText.text = timerString + MiscUtils.setPrecision(time, 0) 
				+ "\n";
		}
	}
}
