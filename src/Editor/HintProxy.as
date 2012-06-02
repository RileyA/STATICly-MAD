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
		private var posX:TextField = new TextField();
		private var posY:TextField = new TextField();
		private var fontVal:TextField = new TextField();
		private var posLabel:TextField = new TextField();
		private var angLabel:TextField = new TextField();
		private var angVal:TextField = new TextField();
		private var sizeField:EditorVectorOption = null;
		private var isText:EditorOption = null;
		private var hintText:TextField = new TextField();

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

			fontVal = new TextField();
			fontVal.defaultTextFormat = textFormat;
			fontVal.text = m_child.info.textSize.toString();
			fontVal.x = 100;
			fontVal.y = 100;
			fontVal.width = 45;
			fontVal.height = 12;
			fontVal.type = TextFieldType.INPUT;
			fontVal.border = true;
			fontVal.alpha = 1;
			fontVal.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			fontVal.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			fontVal.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(fontVal);

			hintText = new TextField();
			hintText.defaultTextFormat = textFormat;
			hintText.text = m_child.info.text;
			hintText.x = 4;
			hintText.y = 78;
			hintText.width = 140;
			hintText.height = 12;
			hintText.type = TextFieldType.INPUT;
			hintText.border = true;
			hintText.alpha = 1;
			hintText.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			hintText.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			hintText.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(hintText);

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

			posLabel = new TextField();
			posLabel.defaultTextFormat = textFormat;
			posLabel.text = "Font Size: ";
			posLabel.x = 4;
			posLabel.y = 100;
			posLabel.width = 70;
			posLabel.height = 12;
			posLabel.border = false;
			posLabel.alpha = 1;
			form.addChild(posLabel);

			var opts:Vector.<String> = new Vector.<String>();
			opts.push("Text", "Arrow");
			isText = new EditorOption(opts, "Hint Type", 
				m_child.info.textHint ? 0 : 1);
			isText.x = 4;
			isText.y = 22;
			form.addChild(isText);
			isText.addEventListener(Event.CHANGE, handlePropChange);

			angLabel = new TextField();
			angLabel.defaultTextFormat = textFormat;
			angLabel.text = "Angle (Deg):";
			angLabel.x = 4;
			angLabel.y = 40;
			angLabel.width = 70;
			angLabel.height = 12;
			angLabel.border = false;
			angLabel.alpha = 1;
			form.addChild(angLabel);

			angVal = new TextField();
			angVal.defaultTextFormat = textFormat;
			angVal.text = Number(m_child.rotation*180.0/Math.PI).toFixed(4);
			angVal.x = 75;
			angVal.y = 40;
			angVal.width = 70;
			angVal.height = 12;
			angVal.type = TextFieldType.INPUT;
			angVal.border = true;
			angVal.alpha = 1;
			angVal.addEventListener(KeyboardEvent.KEY_UP, 
				EditorMenu.onKey);
			angVal.addEventListener(KeyboardEvent.KEY_DOWN, 
				EditorMenu.onKey);
			angVal.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(angVal);

			sizeField = new EditorVectorOption(
				"Size: ", m_child.im.width / m_child.ppm, 
					m_child.im.height / m_child.ppm);
			sizeField.x = 4;
			sizeField.y = 60;
			form.addChild(sizeField);

			sizeField.addEventListener(Event.CHANGE, handlePropChange);
		}

		public function handlePropChange(e:Event):void {

			m_child.isText = isText.getSelection() == "Text";
			m_child.update();
			x = parseFloat(posX.text) * m_child.ppm;
			y = parseFloat(posY.text) * m_child.ppm;
			m_child.rotation = parseFloat(angVal.text) * Math.PI/180.0;
			m_child.im.width = sizeField.getValue().x * m_child.ppm;
			m_child.im.height = sizeField.getValue().y * m_child.ppm;
			m_child.info.text = hintText.text;

			if (m_child.isText) {

				var nm:Number = 0;
				var strs:Array = m_child.info.text.split(',');
				for (var k:uint=0; k < strs.length; ++k)
					nm = Math.max(nm, strs[k].length);

				var newWidth:Number = Math.max(m_child.info.textSize *
					nm * 0.8, m_child.txt.width);
				var newHeight:Number = Math.max(m_child.info.textSize * 1.75 *
					strs.length, m_child.txt.height);

				m_child.info.textSize = !isNaN(parseInt(fontVal.text)) ?
					parseInt(fontVal.text) : m_child.info.textSize;
				m_child.txt.fontSize = m_child.info.textSize;

				m_child.txt.width = newWidth;
				m_child.im.width = newWidth;
				m_child.txt.height = newHeight;
				m_child.im.height = newHeight;
				m_child.update();
				loseFocus();
				gainFocus();
			}

			if (m_child.txt) {
				//m_child.txt.width = sizeField.getValue().x * m_child.ppm;
				//m_child.txt.height = sizeField.getValue().y * m_child.ppm;
				m_child.txt.x = -m_child.im.width / 2;
				m_child.txt.y = -m_child.im.height / 2;
			}

			m_child.im.x = -m_child.im.width / 2;
			m_child.im.y = -m_child.im.height / 2;
			m_child.x = x + m_child.im.width / 2;
			m_child.y = y + m_child.im.height / 2;
			//m_child.txt.text = hintText.text;

			m_child.info.x = //parseFloat(posX.text);
				m_child.x / m_child.ppm;
			m_child.info.y = //parseFloat(posY.text);
				m_child.y / m_child.ppm;
			m_child.info.ang = parseFloat(angVal.text);
			m_child.info.w = m_child.txt.width / m_child.ppm;
			m_child.info.h = m_child.txt.height / m_child.ppm;
			m_child.info.textHint = m_child.isText;

			reposition();
		}

		public function getCaption():String {
			return "Hint";
		}

		public function updateForm():void {
			posX.text = Number(x / m_child.ppm).toFixed(4);
			posY.text = Number(y / m_child.ppm).toFixed(4);
			angVal.text = Math.round(
				Number(m_child.rotation * 180.0/Math.PI)).toString();
			m_child.info.x = //parseFloat(posX.text);
				m_child.x / m_child.ppm;
			m_child.info.y = //parseFloat(posY.text);
				m_child.y / m_child.ppm;
		}

		public function getHint():Hint {
			return m_child;
		}
	}
}
