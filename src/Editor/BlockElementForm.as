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
	import flash.utils.*;

	public class BlockElementForm extends Sprite {
		
		private var labels:Vector.<TextField>;
		private var selectionLabels:Vector.<TextField>;
		private var leftBtns:Vector.<SimpleButton>;
		private var rightBtns:Vector.<SimpleButton>;
		public var options:Vector.<String>;
		public var selections:Vector.<int>;
		
		public function BlockElementForm(opts:Vector.<String>, 
			vals:Vector.<int>):void {
			labels = new Vector.<TextField>();
			selectionLabels = new Vector.<TextField>();
			leftBtns = new Vector.<SimpleButton>();
			rightBtns = new Vector.<SimpleButton>();
			options = opts;
			selections = vals;
			makeDirection("UP", 0, 0);
			makeDirection("DOWN", 15, 1);
			makeDirection("LEFT", 30, 2);
			makeDirection("RIGHT", 45, 3);
		}

		private function makeDirection(dir:String, ypos:Number, i:int):void {
			var textFormat:TextFormat = new TextFormat("Sans", 8, 0x000000);
			var textButtonFormat:TextFormat = new TextFormat(
				"Sans", 8, 0x000000);
			textButtonFormat.align = "center";
			var lbl:TextField = new TextField();
			lbl.defaultTextFormat = textFormat;
			lbl.text = dir;
			lbl.x = 0;
			lbl.y = ypos;
			lbl.width = 30;
			lbl.height = 12;
			addChild(lbl);
			labels.push(lbl);

			lbl = new TextField();
			lbl.defaultTextFormat = textButtonFormat;
			lbl.text = options[selections[i]];
			lbl.x = 50;
			lbl.y = ypos;
			lbl.width = 76;
			lbl.height = 12;
			addChild(lbl);
			selectionLabels.push(lbl);

			var btn:SimpleButton = new SimpleButton();
			EditorMenu.makeButtonStates(btn, "<", 15, 12,
				textButtonFormat);
			btn.x = 35;
			btn.y = ypos;
			btn.width = 15;
			btn.height = 12;
			btn.addEventListener(MouseEvent.CLICK, clickedLeft);
			addChild(btn);
			leftBtns.push(btn);

			btn = new SimpleButton();
			EditorMenu.makeButtonStates(btn, ">", 15, 12,
				textButtonFormat);
			btn.x = 126;
			btn.y = ypos;
			btn.width = 15;
			btn.height = 12;
			btn.addEventListener(MouseEvent.CLICK, clickedRight);
			addChild(btn);
			rightBtns.push(btn);
		}

		public function clickedLeft(e:MouseEvent):void {
			for (var i:int = 0; i < 4; ++i) {
				if (e.target == leftBtns[i] || e.target.parent 
					== leftBtns[i])
				{
					selections[i] = selections[i] - 1;
					if (selections[i] < 0) selections[i] = options.length - 1;
					selectionLabels[i].text = options[selections[i]];
					dispatchEvent(new Event(Event.CHANGE));
					return;
				}
			}
		}

		public function clickedRight(e:MouseEvent):void {
			for (var i:int = 0; i < 4; ++i) {
				if (e.target ==rightBtns[i] || e.target.parent 
					== rightBtns[i])
				{
					selections[i] = selections[i] + 1;
					if (selections[i] > options.length - 1) selections[i] = 0;
					selectionLabels[i].text = options[selections[i]];
					dispatchEvent(new Event(Event.CHANGE));
					return;
				}
			}
		}

		public function getSelection(dir:String):String {
			if (dir == "up") return options[selections[0]];
			else if (dir == "down") return options[selections[1]];
			else if (dir == "left") return options[selections[2]];
			else return options[selections[3]];
		}
	}
}
