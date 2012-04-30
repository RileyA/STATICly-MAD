package Editor {
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import flash.display.Shape;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;

	/** A scalable containing a block, lets you take a block and scale
		it and drag it around and such */
	public class BlockProxy extends Scalable implements EditorProxy {
		
		private var m_child:Block;

		private var posLabel:TextField = new TextField();
		private var scaleLabel:TextField = new TextField();
		private var xpos:TextField = new TextField();
		private var ypos:TextField = new TextField();
		private var xscale:TextField = new TextField();
		private var yscale:TextField = new TextField();

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

		public function populateForm(form:Sprite):void {
			var textFormat:TextFormat = new TextFormat("Sans", 8, 0x000000);
			xpos.defaultTextFormat = textFormat;
			xpos.text = Number(x / m_child.scaleX).toFixed(4);
			xpos.x = 53;
			xpos.y = 4;
			xpos.width = 45;
			xpos.height = 12;
			xpos.type = TextFieldType.INPUT;
			xpos.border = true;
			xpos.alpha = 1;
			xpos.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			xpos.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			xpos.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(xpos);

			ypos = new TextField();
			ypos.defaultTextFormat = textFormat;
			ypos.text = Number(y / m_child.scaleY).toFixed(4);
			ypos.x = 100;
			ypos.y = 4;
			ypos.width = 45;
			ypos.height = 12;
			ypos.type = TextFieldType.INPUT;
			ypos.border = true;
			ypos.alpha = 1;
			ypos.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			ypos.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			ypos.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(ypos);

			xscale.defaultTextFormat = textFormat;
			xscale.text = Number(m_child.getScale().x).toFixed(4);
			xscale.x = 53;
			xscale.y = 19;
			xscale.width = 45;
			xscale.height = 12;
			xscale.type = TextFieldType.INPUT;
			xscale.border = true;
			xscale.alpha = 1;
			xscale.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			xscale.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			xscale.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(xscale);

			yscale = new TextField();
			yscale.defaultTextFormat = textFormat;
			yscale.text = Number(m_child.getScale().y).toFixed(4);
			yscale.x = 100;
			yscale.y = 19;
			yscale.width = 45;
			yscale.height = 12;
			yscale.type = TextFieldType.INPUT;
			yscale.border = true;
			yscale.alpha = 1;
			yscale.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			yscale.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			yscale.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(yscale);

			posLabel = new TextField();
			posLabel.defaultTextFormat = textFormat;
			posLabel.text = "Start Pos: ";
			posLabel.x = 4;
			posLabel.y = 4;
			posLabel.width = 70;
			posLabel.height = 12;
			posLabel.border = false;
			posLabel.alpha = 1;
			form.addChild(posLabel);

			scaleLabel = new TextField();
			scaleLabel.defaultTextFormat = textFormat;
			scaleLabel.text = "Scale: ";
			scaleLabel.x = 4;
			scaleLabel.y = 19;
			scaleLabel.width = 70;
			scaleLabel.height = 12;
			scaleLabel.border = false;
			scaleLabel.alpha = 1;
			form.addChild(scaleLabel);
		}

		public function updateForm():void {
			// ...
		}

		public function getCaption():String {
			return "Block";
		}

		public function handlePropChange(e:Event):void {
			// if scale, we can just reuse
			if (e.target == xpos || e.target == ypos) {
				x = parseFloat(xpos.text) * m_child.scaleX;
				y = parseFloat(ypos.text) * m_child.scaleY;
				reposition();
			// otherwise we need to reinit the whole thang
			} else {
				m_child.getInfo().scale.x = parseFloat(xscale.text);
				m_child.getInfo().scale.y = parseFloat(yscale.text);
				forceScale(m_child.getInfo().scale.x * m_child.scaleX, 
					m_child.getInfo().scale.y * m_child.scaleY);
				m_child.getInfo().position.x = parseFloat(xpos.text) 
					+ m_child.getInfo().scale.x/2;
				m_child.getInfo().position.y = parseFloat(ypos.text)
					+ m_child.getInfo().scale.y/2;
				m_child.reinit();
			}
		}
	}
}
