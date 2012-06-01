package Editor {
	import flash.display.*;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;

	public class HintProxy extends Draggable implements EditorProxy {
		
		private var m_child:Hint;
		private static var posX:TextField = new TextField();
		private static var posY:TextField = new TextField();
		private static var posLabel:TextField = new TextField();

		public function HintProxy(h:Hint):void {
			m_child = h;
			//h.ppm = 1;
			super(h.x-h.im.width/2, h.y-h.im.height/2 ,
				h.im.width, h.im.height);
			// snap to pixels...
			super.setSnap(1.0);
			x = m_child.x - m_child.im.width / 2;
			y = m_child.y - m_child.im.height / 2;
		}

		override public function reposition():void {
			super.reposition();
			m_child.x = x + m_child.im.width / 2;
			m_child.y = y + m_child.im.height / 2;
		}

		override public function makeSprite(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			var tmp:Shape = new Shape();
			alpha = 0.4;
			tmp.graphics.lineStyle(3.0,0xcc9999,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xffaaaa);
			tmp.graphics.drawRect(0, 0, scale_x, scale_y);
			tmp.graphics.endFill();
			addChild(tmp);
		}

		override public function beginDrag():void { 
			posLabel.text = "DRAGGED";
		}

		override public function endDrag():void {
		}

		public function gainFocus():void {
			alpha = 0.7;
			var tmp:Shape = getChildAt(0) as Shape;
			tmp.graphics.clear();
			tmp.graphics.lineStyle(3.0,0x99cc99,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xaaffaa);
			tmp.graphics.drawRect(0, 0, m_child.im.width,
				m_child.im.height);
			tmp.graphics.endFill();
		}

		public function loseFocus():void {
			alpha = 0.2;
			var tmp:Shape = getChildAt(0) as Shape;
			tmp.graphics.clear();
			tmp.graphics.lineStyle(3.0,0xcc9999,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xffaaaa);
			tmp.graphics.drawRect(0, 0, m_child.im.width, m_child.im.height);
			tmp.graphics.endFill();
		}

		public function populateForm(form:Sprite):void {
			var textFormat:TextFormat = new TextFormat("Sans", 8, 0x000000);
			posX.defaultTextFormat = textFormat;
			posX.text = Number(x / m_child.ppm).toFixed(4);
			posX.x = 53;
			posX.y = 4;
			posX.width = 45;
			posX.height = 12;
			posX.type = TextFieldType.INPUT;
			posX.border = true;
			posX.alpha = 1;
			posX.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			posX.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			posX.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(posX);

			posY = new TextField();
			posY.defaultTextFormat = textFormat;
			posY.text = Number(y / m_child.ppm).toFixed(4);
			posY.x = 100;
			posY.y = 4;
			posY.width = 45;
			posY.height = 12;
			posY.type = TextFieldType.INPUT;
			posY.border = true;
			posY.alpha = 1;
			posY.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			posY.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			posY.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(posY);

			posLabel = new TextField();
			posLabel.defaultTextFormat = textFormat;
			posLabel.text = "Pos: ";
			posLabel.x = 4;
			posLabel.y = 4;
			posLabel.width = 70;
			posLabel.height = 12;
			posLabel.border = false;
			posLabel.alpha = 1;
			form.addChild(posLabel);
		}

		public function handlePropChange(e:Event):void {
			x = parseFloat(posX.text) * m_child.ppm;
			y = parseFloat(posY.text) * m_child.ppm;
			reposition();
		}

		public function getCaption():String {
			return "Hint";
		}

		public function updateForm():void {
			posX.text = Number(x / m_child.ppm).toFixed(4);
			posY.text = Number(y / m_child.ppm).toFixed(4);
		}

		public function getHint():Hint {
			return m_child;
		}
	}
}
