package Editor {

	import flash.display.Shape;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;

	public class EditorOption extends Sprite {
		
		private var label:TextField;
		private var options:Vector.<SimpleButton>;
		private var optionNames:Vector.<String>;
		private var currentSelection:uint;
		private var selectedSprite:Sprite;
		private var textButtonFormat:TextFormat;
		private var w:Number;

		public function EditorOption(opts:Vector.<String>, caption:String, 
			def:uint) {
			textButtonFormat = new TextFormat("Sans", 8, 0x000000);
			currentSelection = def;
			optionNames = opts;
			options = new Vector.<SimpleButton>();
			label = new TextField();
			label.defaultTextFormat = textButtonFormat;
			label.text = caption ? caption : "";
			label.x = 0;
			label.y = 0;
			label.height = 12;
			label.border = false;
			addChild(label);
			textButtonFormat.align = "center";
			var offset:Number = (opts.length == 3) ? 40 : 75;
			label.width = offset;
			w = 30;
			if (caption == null) {
				w = 45;
				offset = 0;
			}

			for (var i:uint = 0; i < opts.length; ++i) {
				var btn:SimpleButton = new SimpleButton();
				EditorMenu.makeButtonStates(btn, opts[i], w, 12,
					textButtonFormat);
				btn.x = offset + i * (w+5);
				btn.y = 0;
				btn.width = w;
				btn.height = 12;
				btn.addEventListener(MouseEvent.CLICK, clicked);
				addChild(btn);
				options.push(btn);
			}

			EditorMenu.makeActiveButtonStates(options[currentSelection], 
				optionNames[currentSelection],
				w, 12, textButtonFormat);
		}
		
		public function clicked(e:MouseEvent):void {
			for (var i:uint = 0; i < options.length; ++i) {
				if (options[i] == e.target && i != currentSelection) {
					EditorMenu.makeButtonStates(options[currentSelection], 
						optionNames[currentSelection],
						w, 12, textButtonFormat);
					currentSelection = i;
					EditorMenu.makeActiveButtonStates(options[currentSelection], 
						optionNames[currentSelection],
						w, 12, textButtonFormat);
					dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}

		public function getSelection():String {
			return optionNames[currentSelection];
		}
	}

}
