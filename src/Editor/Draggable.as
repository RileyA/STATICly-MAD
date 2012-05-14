package Editor {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	import flash.ui.Keyboard;
	import flash.geom.Point;

	public class Draggable extends Sprite {

		private var xclick:Number;
		private var yclick:Number;
		public var dragged:Boolean = false;
		public var snapTo:Number = 0.25;
		public var snapOffsetX:Number = 0;
		public var snapOffsetY:Number = 0;
		public var par:DisplayObjectContainer;
		private static const DISABLE_SNAP_KEY:Number = Keyboard.SPACE;

		public function Draggable(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			makeSprite(pos_x, pos_y, scale_x, scale_y);
			addEventListener(MouseEvent.MOUSE_DOWN, grab);
			x = pos_x;
			y = pos_y;
			snapOffsetX = 0;//-width / 2;
			snapOffsetY = 0;//-height / 2;
		}

		public function setParentContext(p:DisplayObjectContainer):void {
			par = p;
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
			xclick = mouseX;
			yclick = mouseY;
			dragged = true;
			if (e.target.parent == this)
				e.target.removeEventListener(MouseEvent.MOUSE_DOWN, grab);
			else
				removeEventListener(MouseEvent.MOUSE_DOWN, grab);
			//startDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
			stage.addEventListener(MouseEvent.MOUSE_UP, drop);
			//stage.addEventListener(Event.MOUSE_LEAVE, drop);
			//e.stopPropagation();
		}

		public function drop(e:Event):void {
			endDrag();
			dragged = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, drop);
			//stage.removeEventListener(Event.MOUSE_LEAVE, drop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			//stopDrag();
			if (e.target.parent == this)
				e.target.addEventListener(MouseEvent.MOUSE_DOWN, grab);
			else
				addEventListener(MouseEvent.MOUSE_DOWN, grab);
			//e.stopPropagation();
		}

		public function drag(e:MouseEvent):void {
			
			e.updateAfterEvent();

			// global mouse pos
			if (dragged)
			{
				var mouseGlobal:Point = new Point(stage.mouseX, stage.mouseY);
				var clickGlobal:Point = new Point(xclick, yclick);

				var snapSpace:DisplayObjectContainer = (par is Draggable) ? par.parent : par;
				var localPos:Point = snapSpace.globalToLocal(mouseGlobal);

				var x_next:Number = Keys.isKeyPressed(DISABLE_SNAP_KEY) ? localPos.x - xclick 
					: Math.round((localPos.x - xclick + snapOffsetX)/snapTo) * snapTo;
				var y_next:Number = Keys.isKeyPressed(DISABLE_SNAP_KEY) ? localPos.y - yclick 
					: Math.round((localPos.y - yclick + snapOffsetY)/snapTo) * snapTo;

				if (snapSpace == par) {
					x = x_next - snapOffsetX;
					y = y_next - snapOffsetY;
				} else {
					x = x_next - par.x - snapOffsetX;
					y = y_next - par.y - snapOffsetY;
				}
			}

			reposition();
			//e.stopPropagation();
		}

		public function setSnap(snap:Number):void {
			snapTo = snap;
		}

		public function reposition():void {
			
		}

		public function beginDrag():void {

		}

		public function endDrag():void {

		}
	}
}

