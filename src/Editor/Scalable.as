package Editor {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.*;

	public class Scalable extends Draggable {

		private var m_corners:Vector.<Draggable>;

		private var m_drag:Number = 0;
		private var m_anchor:Number = 0;
		private var m_dragging:Boolean = false;
		protected var m_scale_x:Number;
		protected var m_scale_y:Number;
		protected var m_children:Vector.<Sprite>;
		public var m_scalepx_x:Number;
		public var m_scalepx_y:Number;

		private static const WIDGET_DIMENSIONS:Number = 7;
		
		public function Scalable(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			m_corners = new Vector.<Draggable>();
			m_children = new Vector.<Sprite>();
			super(pos_x, pos_y, scale_x, scale_y);
			m_scale_x = scale_x;
			m_scale_y = scale_y;
			m_scalepx_x = scale_x;
			m_scalepx_y = scale_y;
			m_corners.push(new Draggable(0,0,
				WIDGET_DIMENSIONS, WIDGET_DIMENSIONS));
			m_corners.push(new Draggable(0, scale_y - WIDGET_DIMENSIONS,
				WIDGET_DIMENSIONS, WIDGET_DIMENSIONS));
			m_corners.push(new Draggable(scale_x - WIDGET_DIMENSIONS,0,
				WIDGET_DIMENSIONS, WIDGET_DIMENSIONS));
			m_corners.push(new Draggable(scale_x - WIDGET_DIMENSIONS,
				scale_y - WIDGET_DIMENSIONS, WIDGET_DIMENSIONS, WIDGET_DIMENSIONS));
			for (var i:uint = 0; i < m_corners.length; ++i) {
				addChild(m_corners[i]);
				//m_corners[i].snapOffsetX = WIDGET_DIMENSIONS/2;
				//m_corners[i].snapOffsetY = WIDGET_DIMENSIONS/2;
			}

			m_corners[0].snapOffsetX = 0;
			m_corners[0].snapOffsetY = 0;
			m_corners[1].snapOffsetX = 0;
			m_corners[1].snapOffsetY = 0;
			m_corners[2].snapOffsetX = 0;
			m_corners[2].snapOffsetY = 0;
			m_corners[3].snapOffsetX = 0;
			m_corners[3].snapOffsetY = 0;
			snapOffsetX = 0;
			snapOffsetY = 0;
		}

		override public function setParentContext(p:DisplayObjectContainer):void {
			par = p;
			for (var i:uint = 0; i < m_corners.length; ++i) {
				m_corners[i].par = this;
			}
		}

		override public function setSnap(snap:Number):void {
			snapTo = snap;
			for (var i:uint = 0; i < m_corners.length; ++i) {
				m_corners[i].snapTo = snap;
			}
		}

		override public function makeSprite(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			var dragger:Sprite = new Sprite();
			var tmp:Shape = new Shape();
			dragger.alpha = 0.2;
			tmp.graphics.lineStyle(3.0,0xcc9999,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xffaaaa);
			tmp.graphics.drawRect(0, 0, scale_x, scale_y);
			tmp.graphics.endFill();
			dragger.addChild(tmp);
			pushChild(dragger);
		}

		public function pushChild(child:Sprite):void {
			m_children.push(child);
			child.addEventListener(MouseEvent.MOUSE_DOWN, grab);
			addChild(child);
		}

		override public function grab(e:MouseEvent):void{
			if (!isTarget(e.target as Sprite)) {

				m_corners[0].snapOffsetX = 0;
				m_corners[0].snapOffsetY = 0;
				m_corners[1].snapOffsetX = 0;
				m_corners[1].snapOffsetY = 0;
				m_corners[2].snapOffsetX = 0;
				m_corners[2].snapOffsetY = 0;
				m_corners[3].snapOffsetX = 0;
				m_corners[3].snapOffsetY = 0;

				var index:uint = m_corners.length;
				beginDrag();

				// decide which corner we're at..
				for (var i:uint = 0; i < m_corners.length; ++i) {
					if (m_corners[i] == e.target) {
						index = i;
						break;
					}
				}

				var index2:uint = index == 0 ? 1 : 0;

				// and which should be the "anchor"			
				for (i = 0; i < m_corners.length; ++i) {
					if (i == index || m_corners[i].x == m_corners[index].x 
						|| m_corners[i].y == m_corners[index].y)
						continue;
					index2 = i;
				}

				if (index2 >= m_corners.length || index >= m_corners.length) {
					super.grab(e);
					return;
				}

				if (m_corners[index2].x < m_corners[index].x) {
					m_corners[index].snapOffsetX = WIDGET_DIMENSIONS;
				}
				if (m_corners[index2].y < m_corners[index].y) {
					m_corners[index].snapOffsetY = WIDGET_DIMENSIONS;
				}

				m_dragging = true;
				m_drag = index;
				m_anchor = index2;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
				stage.addEventListener(MouseEvent.MOUSE_UP, drop);

			} else {
				super.grab(e);
			}
		}

		override public function drag(e:MouseEvent):void {
			if (!isTarget(e.target as Sprite) && m_dragging) {
				reposition();
			} else {
				super.drag(e);
			}
		}

		override public function drop(e:Event):void {
			if (!isTarget(e.target as Sprite)) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, drop);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
				endDrag();
				if (m_dragging) {
					m_dragging = false;
				}
			} else {
				super.drop(e);
				reposition();
			}
		}

		public function isTarget(t:Sprite):Boolean {
			if (t == this) return true;
			var isT:Boolean = false;
			for (var i:uint=0;i<m_children.length;++i) isT = isT || t == m_children[i];
			return isT;
		}

		override public function reposition():void {
			var first:Boolean = false;
			if (m_dragging) {
				for (var i:uint = 0; i < m_corners.length; ++i) {
					if (i == m_anchor || i == m_drag)
						continue;

					if (!first) {
						m_corners[i].x = m_corners[m_anchor].x;
						m_corners[i].y = m_corners[m_drag].y;
					} else {
						m_corners[i].x = m_corners[m_drag].x;
						m_corners[i].y = m_corners[m_anchor].y;
					}

					first = true;
				}
			} else {
				m_anchor = 0;
				for (i = 0; i < m_corners.length; ++i) {
					if (i == m_anchor || m_corners[i].x == m_corners[m_anchor].x 
						|| m_corners[i].y == m_corners[m_anchor].y)
						continue;
					m_drag = i;
				}
			}
			for (i = 0; i < m_children.length; ++i) {
				m_children[i].x = Math.min(m_corners[m_anchor].x, m_corners[m_drag].x);
				m_children[i].y = Math.min(m_corners[m_anchor].y, m_corners[m_drag].y);

				m_scalepx_x = (Math.max(m_corners[m_anchor].x, m_corners[m_drag].x) 
					- m_children[i].x + WIDGET_DIMENSIONS);
				m_scalepx_y = (Math.max(m_corners[m_anchor].y, m_corners[m_drag].y) 
					- m_children[i].y + WIDGET_DIMENSIONS);
				m_children[i].scaleX = (Math.max(m_corners[m_anchor].x, m_corners[m_drag].x) 
					- m_children[i].x + WIDGET_DIMENSIONS) / m_scale_x;
				m_children[i].scaleY = (Math.max(m_corners[m_anchor].y, m_corners[m_drag].y) 
					- m_children[i].y + WIDGET_DIMENSIONS) / m_scale_y;
			}

			m_scalepx_x = Math.max(m_corners[m_anchor].x, m_corners[m_drag].x) 
				- Math.min(m_corners[m_anchor].x, m_corners[m_drag].x) + WIDGET_DIMENSIONS;
			m_scalepx_y = Math.max(m_corners[m_anchor].y, m_corners[m_drag].y) 
				- Math.min(m_corners[m_anchor].y, m_corners[m_drag].y) + WIDGET_DIMENSIONS;
		}

		public function forceScale(sx:Number, sy:Number):void {

			//var index:uint = 0;
			//var minx:Number = 5000;
			//var miny:Number = 5000;
			//for (var i:uint = 0; i < 4; ++i) {
			//	if (m_conrers[i].x == minx)
			//}

			/*for (i = 0; i  < 4; ++i) {
				if (i != m_anchor) {
					m_corners[i].x = sx - ((m_corners[i].x > m_corners[m_anchor].x) ? WIDGET_DIMENSIONS : 0);
					m_corners[i].y = sy - ((m_corners[i].y > m_corners[m_anchor].y) ? WIDGET_DIMENSIONS : 0);
				}
			}

			m_corners[m_drag].x = sx + WIDGET_DIMENSIONS;
			m_corners[m_drag].y = sy + WIDGET_DIMENSIONS;*/

			m_corners[0].x = 0;
			m_corners[0].y = 0;
			m_corners[1].x = sx - WIDGET_DIMENSIONS;
			m_corners[1].y = sy - WIDGET_DIMENSIONS;
			m_corners[2].x = 0;;//
			m_corners[2].y = sy - WIDGET_DIMENSIONS;
			m_corners[3].x = sx - WIDGET_DIMENSIONS;
			m_corners[3].y = 0;
			//m_scale_x = sx;
			//m_scale_y = sy;
			reposition();
		}
	}
}
