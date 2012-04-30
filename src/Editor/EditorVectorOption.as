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

	public class EditorVectorOption extends Sprite {

	private var label:TextField;
	private var xval:TextField;
	private var yval:TextField;


		public function EditorVectorOption(cap:String, xv:Number, yv:Number)
			:void {
			var textFormat:TextFormat = new TextFormat("Sans", 8, 0x000000);
			
			xval = new TextField();
			xval.defaultTextFormat = textFormat;
			xval.text = xv.toFixed(4);
			xval.x = 53;
			xval.y = 0;
			xval.width = 45;
			xval.height = 12;
			xval.type = TextFieldType.INPUT;
			xval.border = true;
			xval.alpha = 1;
			xval.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			xval.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			xval.addEventListener(Event.CHANGE, changed);
			addChild(xval);

			yval = new TextField();
			yval.defaultTextFormat = textFormat;
			yval.text = yv.toFixed(4);
			yval.x = 100;
			yval.y = 0;
			yval.width = 45;
			yval.height = 12;
			yval.type = TextFieldType.INPUT;
			yval.border = true;
			yval.alpha = 1;
			yval.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			yval.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			yval.addEventListener(Event.CHANGE, changed);
			addChild(yval);

			label = new TextField();
			label.defaultTextFormat = textFormat;
			label.text = cap;
			label.x = 0;
			label.y = 0;
			label.width = 50;
			label.height = 12;
			addChild(label);
		}

		public function getValue():UVec2 {
			return new UVec2(parseFloat(xval.text), parseFloat(yval.text));
		}

		public function setValue(val:UVec2):void {
			xval.text = val.x.toFixed(4);
			yval.text = val.y.toFixed(4);
		}

		public function changed(e:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}

