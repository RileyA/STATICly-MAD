package Editor {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.events.KeyboardEvent;

	/** This is a big mess, but it gets the job done... */
	public class EditorMenu extends Draggable {

		public var body:Sprite;
		public var levelName:TextField;
		public var levelW:TextField;
		public var levelH:TextField;
		public var textFormat:TextFormat;
		public var textButtonFormat:TextFormat;
		public var newButton:SimpleButton;
		public var saveButton:SimpleButton;
		public var loadButton:SimpleButton;
		
		public function EditorMenu(name:String):void {
			super(0,0,150,15);
			body = new Sprite();
			addChild(body);
			body.y = 15;
			var s:Shape = new Shape();
			s.graphics.beginFill(0xcccccc);
			s.graphics.lineStyle(2.0,0x777777,1.0,false,LineScaleMode.NONE);
			s.graphics.drawRect(1,0,148,335);
			s.graphics.endFill();
			body.addChild(s);
			body.alpha = 0.75;
			body.addEventListener(MouseEvent.MOUSE_DOWN, onClick);

			textFormat = new TextFormat("Sans", 8, 0x000000);
			textButtonFormat = new TextFormat("Sans", 8, 0x000000);
			textButtonFormat.align = "center";

			var levelNameCaption:TextField = new TextField();
			levelNameCaption.defaultTextFormat = textFormat;
			levelNameCaption.text = "Level Name: ";
			levelNameCaption.x = 4;
			levelNameCaption.y = 19;
			levelNameCaption.width = 70;
			levelNameCaption.height = 12;
			levelNameCaption.selectable = false;
			body.addChild(levelNameCaption);

			levelName = new TextField();
			levelName.defaultTextFormat = textFormat;
			levelName.text = name;
			levelName.x = 74;
			levelName.y = 19;
			levelName.width = 70;
			levelName.height = 12;
			levelName.type = TextFieldType.INPUT;
			levelName.border = true;
			levelName.addEventListener(KeyboardEvent.KEY_UP, onKey);
			levelName.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			body.addChild(levelName);

			saveButton = new SimpleButton();
			makeButtonStates(saveButton, "Save", 70, 12);
			saveButton.x = 4;
			saveButton.y = 3;
			saveButton.height = 12;
			body.addChild(saveButton);

			loadButton = new SimpleButton();
			makeButtonStates(loadButton, "Load", 70, 12);
			loadButton.x = 78;
			loadButton.y = 4;
			loadButton.height = 12;
			body.addChild(loadButton);

			levelW = new TextField();
			levelW.defaultTextFormat = textFormat;
			levelW.text = "26.666";
			levelW.x = 4;
			levelW.y = 35;
			levelW.width = 45;
			levelW.height = 12;
			levelW.type = TextFieldType.INPUT;
			levelW.border = true;
			levelW.addEventListener(KeyboardEvent.KEY_UP, onKey);
			levelW.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			body.addChild(levelW);

			levelH = new TextField();
			levelH.defaultTextFormat = textFormat;
			levelH.text = "20";
			levelH.x = 53;
			levelH.y = 35;
			levelH.width = 45;
			levelH.height = 12;
			levelH.type = TextFieldType.INPUT;
			levelH.border = true;
			levelH.addEventListener(KeyboardEvent.KEY_UP, onKey);
			levelH.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			body.addChild(levelH);

			newButton = new SimpleButton();
			makeButtonStates(newButton, "New Level", 45, 12);
			newButton.x = 100;
			newButton.y = 35;
			newButton.height = 12;
			body.addChild(newButton);
		}

		private function makeButtonStates(btn:SimpleButton, cap:String,
			w:Number, h:Number):void {
			var sprite:Sprite = new Sprite();
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x999999);
			shape.graphics.drawRect(0,0,w,h);
			shape.graphics.endFill();
			sprite.addChild(shape);
			var btnCaption:TextField = new TextField();
			btnCaption.defaultTextFormat = textButtonFormat;
			btnCaption.text = cap;
			btnCaption.width = w;
			btnCaption.height = h;
			btnCaption.selectable = false;
			sprite.addChild(btnCaption);
			btn.upState = sprite;
			btn.hitTestState = sprite;

			sprite = new Sprite();
			shape = new Shape();
			shape.graphics.beginFill(0x777777);
			shape.graphics.drawRect(0,0,w,h);
			shape.graphics.endFill();
			sprite.addChild(shape);
			btnCaption = new TextField();
			btnCaption.defaultTextFormat = textButtonFormat;
			btnCaption.text = cap;
			btnCaption.x = 0;
			btnCaption.y = 0;
			btnCaption.width = w;
			btnCaption.height = h;
			btnCaption.selectable = false;
			sprite.addChild(btnCaption);
			btn.downState = sprite;

			sprite = new Sprite();
			shape = new Shape();
			shape.graphics.beginFill(0xffffff);
			shape.graphics.drawRect(0,0,w,h);
			shape.graphics.endFill();
			sprite.addChild(shape);
			btnCaption = new TextField();
			btnCaption.defaultTextFormat = textButtonFormat;
			btnCaption.text = cap;
			btnCaption.x = 0;
			btnCaption.y = 0;
			btnCaption.width = w;
			btnCaption.height = h;
			btnCaption.selectable = false;
			sprite.addChild(btnCaption);
			btn.overState = sprite;
		}

		override public function makeSprite(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			var tmp:Shape = new Shape();
			tmp.graphics.beginFill(0xababab);
			tmp.graphics.drawRect(0, 0, scale_x, scale_y);
			tmp.graphics.endFill();
			tmp.graphics.beginFill(0x777777);
			for (var i:uint = 0; i < 5; ++i) {
				tmp.graphics.drawRect(0, scale_y / 9 * i * 2, 
					scale_x, scale_y / 9);
			}
			tmp.graphics.endFill();
			addChild(tmp);
		}

		public function onClick(e:MouseEvent):void {
			e.stopPropagation();
		}

		public function onKey(e:KeyboardEvent):void {
			e.stopPropagation();
		}
	}
}
