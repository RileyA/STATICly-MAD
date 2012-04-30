package Editor {
	import flash.display.*;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;

	/** A scalable containing a block, lets you take a block and scale
		it and drag it around and such */
	public class PlayerProxy extends Draggable implements EditorProxy {
		
		private var m_child:Player;

		public function PlayerProxy(p:Player):void {
			m_child = p;
			super(p.x - Player.WIDTH * p.scaleX / 2, p.y,
				Player.WIDTH * p.scaleX, Player.HEIGHT * p.scaleY);
		}

		override public function reposition():void {
			super.reposition();
			var pos:UVec2 = new UVec2(x, y);
			pos.x /= m_child.scaleX;
			pos.y /= m_child.scaleY;
			pos.x += Player.WIDTH/2;
			m_child.setPosition(pos);
			m_child.getPhysics().SetLinearVelocity(new b2Vec2(0,0));
		}

		override public function makeSprite(pos_x:Number, pos_y:Number, 
			scale_x:Number, scale_y:Number):void {
			var tmp:Shape = new Shape();
			alpha = 0.4;
			tmp.graphics.lineStyle(3.0,0xcc9999,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xffaaaa);
			tmp.graphics.drawRect(0, 0, scale_x, scale_y);
			tmp.graphics.endFill();
			addChild(tmp);
		}

		override public function beginDrag():void {
			m_child.getPhysics().SetType(b2Body.b2_staticBody);
		}

		override public function endDrag():void {
			m_child.getPhysics().SetType(b2Body.b2_dynamicBody);
		}

		public function getPos():UVec2 {
			var pos:UVec2 = new UVec2(x, y);
			pos.x /= m_child.scaleX;
			pos.y /= m_child.scaleY;
			pos.x += Player.WIDTH/2;
			return pos;
		}

		public function gainFocus():void {
			alpha = 0.7;
			var tmp:Shape = getChildAt(0) as Shape;
			tmp.graphics.clear();
			tmp.graphics.lineStyle(3.0,0x99cc99,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xaaffaa);
			tmp.graphics.drawRect(0, 0, Player.WIDTH * m_child.scaleX,
				Player.HEIGHT * m_child.scaleY);
			tmp.graphics.endFill();
		}

		public function loseFocus():void {
			alpha = 0.2;
			var tmp:Shape = getChildAt(0) as Shape;
			tmp.graphics.clear();
			tmp.graphics.lineStyle(3.0,0xcc9999,1.0,false,LineScaleMode.NONE);
			tmp.graphics.beginFill(0xffaaaa);
			tmp.graphics.drawRect(0, 0, Player.WIDTH * m_child.scaleX,
				Player.HEIGHT * m_child.scaleY);
			tmp.graphics.endFill();
		}
	}
}
