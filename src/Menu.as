package {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.Quad;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import Colors;
	import MiscUtils;
	import starling.textures.Texture;

	public class Menu extends DisplayObjectContainer {
		
		[Embed(source = "../media/images/sound.png")]
		private static const sound:Class;
		[Embed(source = "../media/images/no_sound.png")]
		private static const no_sound:Class;
		
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
		private var soundImg:Image;
		private var noSoundImg:Image;

		public function Menu():void {

			var bgGradient:Quad = new Quad(800, 25, 0x000000);
			bgGradient.alpha = 0.75;
			addChild(bgGradient);
			bgGradient = new Quad(800, 55, 0x000000);
			bgGradient.y = 25;
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

			titleText = new TextField(300, 2.5*textSize*1.5, "","akashi",textSize*1.5,Colors.textColor);
			titleText.hAlign = "center";
			titleText.vAlign = "top";
			titleText.x = 250;
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
			
			soundImg = initImage(sound);
			soundImg.addEventListener(TouchEvent.TOUCH, mute);
			noSoundImg = initImage(no_sound);
			//soundImg.addEventListener(TouchEvent.TOUCH, unmute);
			
			addChild(bgGradient);
			addChild(exitText);
			addChild(resetText);
			addChild(titleText);
			addChild(timerText);
			addChild(parTimeText);
			addChild(scoreText);
			addChild(soundImg);
		}

		private function initImage(b:Class):Image {
			var result:Image = new Image(Texture.fromBitmap(new b));
			result.height = 16;
			result.width = 16;
			result.x = 780;
			result.y = MENU_Y;
			return result;
		}
		
		private function mute(e:Event):void {
			trace("mute");
			SoundManager.mute();
			removeChild(soundImg);
			addChild(noSoundImg);
		}
		
		private function unmute(e:Event):void {
			trace("unmute");
			SoundManager.unmute();
			removeChild(noSoundImg);
			addChild(soundImg);
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
