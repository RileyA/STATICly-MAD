package Actioners {
	import flash.display.Bitmap;
	import starling.textures.*;
	import starling.display.*;
	import starling.core.*;
	import starling.text.TextField;
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.*;
	import Colors;
	import MiscUtils;
	
	public class LevelEntranceActioner extends ActionerElement {

		public static const WIDTH:Number = 1.0;
		public static const HEIGHT:Number = -1.4;

		[Embed(source = "../../media/images/DoorActive2.png")]
		private static const DoorActive:Class;
		[Embed(source = "../../media/images/DoorInactive.png")]
		private static const DoorInactive:Class;
		[Embed(source = "../../media/images/DoorFinished.png")]
		private static const DoorFinished:Class;

		private var textSprite:TextField;
		private var currImage:Image;
		private var m_levelName:String;
		private var m_levelTitle:String;


		public function LevelEntranceActioner(rectDef:b2BodyDef, offset:b2Vec2, world:b2World, levelName:String):void {
			
			m_levelName=levelName;
			
			var center:b2Vec2 = new b2Vec2(offset.x + WIDTH / 2, offset.y + HEIGHT / 2);
			
			//var format:TextFormat = new TextFormat("Sans", 1, Colors.textColor);
			//format.align = TextFormatAlign.CENTER;
			var textScale:Number=.03;
			var textWidth:Number=WIDTH*200;
			var textSize:Number=16.0;
			textSprite = new TextField(textWidth, 1.5*textSize, "0","Sans",textSize,Colors.textColor);
			textSprite.hAlign = "center";
			
			textSprite.x = -textWidth / 2 * textScale;
			m_levelTitle=MiscUtils.getDisplayName(levelName);
			
			textSprite.visible=false;
			textSprite.scaleX=textScale;
			textSprite.scaleY = textSprite.scaleX;
			
			function cb(level:Level):void {	level.markAsDone(levelName); }
			function tr(player:Player):Boolean { return true; }
			function startHint():void {
				textSprite.visible=true;
			}
			function endHint():void {
				textSprite.visible=false;
			}
			super(rectDef, center, new ActionMarker(cb, tr, null, this, startHint, endHint), world);
		}
		
		public function updateGfx(completedLevels:Vector.<String>):void{
			if (completedLevels.indexOf(m_levelName)!=-1) {
				textSprite.text = m_levelTitle+" (Completed)";
				replaceImage(new DoorFinished());
			} else {
				textSprite.text = m_levelTitle;
				replaceImage(new DoorActive());
			}
		}
		
		override protected function getPolyShape():b2PolygonShape {
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(WIDTH/3, HEIGHT/3);
			return ps;
		}
		
		override protected function getSprite(x:Number, y:Number):DisplayObjectContainer {
			if(spriteContainer == null){
				spriteContainer = new Sprite();
				replaceImage(new DoorActive(), x, y);

				textSprite.y = HEIGHT / 2 + y - .1 - textSprite.height;
				spriteContainer.addChild(textSprite);
			}
			return spriteContainer;
		}

		private function replaceImage(asset:Bitmap, x:int=-1, y:int=-1):void {
			if (currImage != null) {
				x = currImage.x;
				y = currImage.y;
				spriteContainer.removeChild(currImage);
			}
			currImage = new Image(Texture.fromBitmap(asset));
			currImage.x = -WIDTH/2 + x;
			currImage.y = -HEIGHT / 2 + y;
			currImage.height = HEIGHT;
			currImage.width = WIDTH;
			
			spriteContainer.addChild(currImage);
		}
	}
}
