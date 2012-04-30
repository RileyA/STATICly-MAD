package Editor {
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import flash.display.Shape;
	import flash.display.LineScaleMode;

	/** A scalable containing a block, lets you take a block and scale
		it and drag it around and such */
	public class BlockProxy extends Scalable implements EditorProxy {
		
		private var m_child:Block;

		public function BlockProxy(b:Block):void {
			m_child = b;
			var sc:UVec2 = b.getScale();
			super(b.x - sc.x * b.scaleX / 2, b.y -sc.y * b.scaleY / 2,
				sc.x * b.scaleX, sc.y * b.scaleY);
		}

		override public function reposition():void {
			super.reposition();

			var sc:UVec2 = m_child.getScale();

			// x,y + m_children[0].x,y are coords
			var pos:UVec2 = new UVec2(x + m_children[0].x,
				y + m_children[0].y);
			pos.x /= m_child.scaleX;
			pos.y /= m_child.scaleY;
			pos.x += sc.x/2;
			pos.y += sc.y/2;
			m_child.setPosition(pos);
			m_child.clearVelocity();
		}

		override public function beginDrag():void {
			m_child.getPhysics().SetType(b2Body.b2_staticBody);
		}

		override public function endDrag():void {
			var world:b2World = m_child.getPhysics().GetWorld();
			var sc:UVec2 = m_child.getScale();
			var pos:UVec2 = new UVec2(x + m_children[0].x,
				y + m_children[0].y);
			pos.x /= m_child.scaleX;
			pos.y /= m_child.scaleY;
			m_child.getPhysics().SetType(m_child.getBodyType());
			m_child.getInfo().scale.x = m_scalepx_x / m_child.scaleX;
			m_child.getInfo().scale.y = m_scalepx_y / m_child.scaleY;
			m_child.getInfo().position.x = pos.x + m_child.getInfo().scale.x / 2;
			m_child.getInfo().position.y = pos.y + m_child.getInfo().scale.y / 2;
			m_child.reinit();
		}

		public function gainFocus():void {
			m_children[0].alpha = 0.7;
			var tmp:Shape = m_children[0].getChildAt(0) as Shape;
			tmp.graphics.clear();
			tmp.graphics.lineStyle(3.0,0x99cc99,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xaaffaa);
			tmp.graphics.drawRect(0, 0, m_scale_x, m_scale_y);
			tmp.graphics.endFill();
		}

		public function loseFocus():void {
			m_children[0].alpha = 0.2;
			var tmp:Shape = m_children[0].getChildAt(0) as Shape;
			tmp.graphics.clear();
			tmp.graphics.lineStyle(3.0,0xcc9999,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xffaaaa);
			tmp.graphics.drawRect(0, 0, m_scale_x, m_scale_y);
			tmp.graphics.endFill();
		}
	}
}
