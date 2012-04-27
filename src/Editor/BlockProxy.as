package Editor {
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;

	/** A scalable containing a block, lets you take a block and scale
		it and drag it around and such */
	public class BlockProxy extends Scalable {
		
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
			m_child.getPhysics().SetType(m_child.getBodyType());
		}
	}
}
