package Editor {
	//import flash.event.Event;
	//import flash.event.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Shape;

	public class Draggable extends Sprite {
		public function Draggable():void {
			var tmp:Shape = new Shape();
			tmp.graphics.beginFill(0xff0000);
			tmp.graphics.drawRect(0, 0, 50, 50);
			tmp.graphics.endFill();
			addChild(tmp);
		}

		/*public function handleClick(evt:MouseEvent):void {

		}

		public function handleUnclick(evt:MouseEvent):void {

		}*/
	}
}

