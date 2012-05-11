package Actioners {
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.display.Quad;
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.*;
	import starling.text.TextField;
	import Colors;
	import MiscUtils;
	import flash.geom.ColorTransform;
	
	public class LevelEntranceActioner extends ActionerElement {

		public static const WIDTH:Number = 1.0;
		public static const HEIGHT:Number = -1.4;
		private var textSprite:TextField;
		private var m_levelName:String;
		private var m_levelTitle:String;
		private var s:DisplayObjectContainer;

		public function LevelEntranceActioner(rectDef:b2BodyDef, offset:b2Vec2, world:b2World, levelName:String):void {
			
			m_levelName=levelName;
			
			var center:b2Vec2 = new b2Vec2(offset.x, offset.y + HEIGHT / 2);
			
			
			
			//var format:TextFormat = new TextFormat("Sans", 1, Colors.textColor);
			//format.align = TextFormatAlign.CENTER;
			var textWidth:Number=WIDTH*16;
			textSprite = new TextField(textWidth, 10, "", "Sans", 1, Colors.textColor);
			textSprite.hAlign = "center";
			var textScale:Number=.5;
			textSprite.height = 10;
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
			var trans:ColorTransform;
			if (completedLevels.indexOf(m_levelName)!=-1) {
				textSprite.text = m_levelTitle+" (Completed)";
				//trans = new ColorTransform(.6,.6,.6);
			} else {
				textSprite.text = m_levelTitle;
				//trans = new ColorTransform(1.0,1.0,1.0);
			}
			//sprite.transform.colorTransform = trans;
		}
		
		override protected function getPolyShape():b2PolygonShape {
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(WIDTH/3, HEIGHT/3);
			return ps;
		}
		
		override protected function getSprite(x:Number, y:Number):DisplayObjectContainer {
			if (s == null) {
				s = new Sprite();
				var door:Quad = new Quad(WIDTH, HEIGHT, 0xff6600);
				door.x = -WIDTH/2 + x;
				door.y = -HEIGHT / 2 + y;
				s.addChild(door);
				
				textSprite.y = HEIGHT / 2 + y + HEIGHT - .3;
				s.addChild(textSprite);
			}
			return s;
		}
	}
}
