package Editor {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Shape;

	public class Draggable extends Sprite {

		private var xclick:Number;
		private var yclick:Number;
		private var dragged:Boolean;

		public function Draggable(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			makeSprite(pos_x, pos_y, scale_x, scale_y);
			addEventListener(MouseEvent.MOUSE_DOWN, grab);
			x = pos_x;
			y = pos_y;
		}

		public function makeSprite(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			var tmp:Shape = new Shape();
			tmp.graphics.beginFill(0x000000);
			tmp.graphics.drawRect(0, 0, scale_x, scale_y);
			tmp.graphics.endFill();
			addChild(tmp);
		}

		public function grab(e:MouseEvent):void{
			if (e.target != this && e.target.parent != this) return;
			beginDrag();
			if (e.target.parent == this)
				e.target.removeEventListener(MouseEvent.MOUSE_DOWN, grab);
			else
				removeEventListener(MouseEvent.MOUSE_DOWN, grab);
			startDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
			stage.addEventListener(MouseEvent.MOUSE_UP, drop);
		}

		public function drop(e:MouseEvent):void {
			endDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, drop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			stopDrag();
			if (e.target.parent == this)
				e.target.addEventListener(MouseEvent.MOUSE_DOWN, grab);
			else
				addEventListener(MouseEvent.MOUSE_DOWN, grab);
		}

		public function drag(e:MouseEvent):void {
			e.updateAfterEvent();
			reposition();
		}

		public function reposition():void {
			
		}

		public function beginDrag():void {

		}

		public function endDrag():void {

		}
	}
}

