package Editor {
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import flash.display.Shape;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
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

		private var insulatedBox:EditorOption;
		private var strongBox:EditorOption;
		private var movementBox:EditorOption;
		private var polarityBox:EditorOption;
		private var posVec:EditorVectorOption;
		private var scaleVec:EditorVectorOption;
		private var trackPos1:EditorVectorOption;
		private var trackPos2:EditorVectorOption;

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

			posVec = new EditorVectorOption(
				"Pos: ", x / m_child.scaleX, y / m_child.scaleY);
			posVec.x = 4;
			posVec.y = 3;
			form.addChild(posVec);

			scaleVec = new EditorVectorOption(
				"Scale", m_child.getScale().x, m_child.getScale().y);
			scaleVec.x = 4;
			scaleVec.y = 19;
			form.addChild(scaleVec);

			var opts:Vector.<String> = new Vector.<String>();
			opts.push("Yes", "No");
			insulatedBox = new EditorOption(opts, "Insulated", 
				m_child.getInfo().insulated ? 0 : 1);
			insulatedBox.x = 4;
			insulatedBox.y = 35;
			form.addChild(insulatedBox);

			strongBox = new EditorOption(opts, "Strong: ", 
				m_child.getInfo().strong ? 0 : 1);
			strongBox.x = 4;
			strongBox.y = 51;
			form.addChild(strongBox);

			var opts2:Vector.<String> = new Vector.<String>();
			opts2.push("-1", "0", "+1");
			polarityBox = new EditorOption(opts2, "Polarity: ", 
				m_child.getInfo().chargePolarity + 1);
			polarityBox.x = 4;
			polarityBox.y = 66;
			form.addChild(polarityBox);

			var opts3:Vector.<String> = new Vector.<String>();
			opts3.push("fixed", "free", "tracked");
			var m:String = m_child.getInfo().movement;
			var s:uint = 0;
			if (m == "free") s = 1;
			else if (m == "tracked") s = 2;
			movementBox = new EditorOption(opts3, null, s);
			movementBox.x = 4;
			movementBox.y = 82;
			form.addChild(movementBox);

			var xtrack:Number = (m_child.getInfo().bounds.length > 0) ?
				m_child.getInfo().bounds[0].x : -1;
			var ytrack:Number = (m_child.getInfo().bounds.length > 0) ?
				m_child.getInfo().bounds[0].y : 0;
			trackPos1 = new EditorVectorOption(
				"Track Pt. A", xtrack, ytrack);
			trackPos1.x = 4;
			trackPos1.y = 98;
			form.addChild(trackPos1);

			xtrack = (m_child.getInfo().bounds.length > 1) ?
				m_child.getInfo().bounds[1].x : 1;
			ytrack = (m_child.getInfo().bounds.length > 1) ?
				m_child.getInfo().bounds[1].y : 0;
			trackPos2 = new EditorVectorOption(
				"Track Pt. B", xtrack, ytrack);
			trackPos2.x = 4;
			trackPos2.y = 114;
			form.addChild(trackPos2);

			insulatedBox.addEventListener(Event.CHANGE, handlePropChange);
			strongBox.addEventListener(Event.CHANGE, handlePropChange);
			polarityBox.addEventListener(Event.CHANGE, handlePropChange);
			movementBox.addEventListener(Event.CHANGE, handlePropChange);
			posVec.addEventListener(Event.CHANGE, handlePropChange);
			scaleVec.addEventListener(Event.CHANGE, handlePropChange);
			trackPos1.addEventListener(Event.CHANGE, handlePropChange);
			trackPos2.addEventListener(Event.CHANGE, handlePropChange);
		}

		public function updateForm():void {
			// TODO
		}

		public function getCaption():String {
			return "Block";
		}

		public function handlePropChange(e:Event):void {
			x = posVec.getValue().x * m_child.scaleX;
			y = posVec.getValue().y * m_child.scaleY;
			reposition();
			m_child.getInfo().scale.x = scaleVec.getValue().x;
			m_child.getInfo().scale.y = scaleVec.getValue().y;
			forceScale(m_child.getInfo().scale.x * m_child.scaleX, 
				m_child.getInfo().scale.y * m_child.scaleY);
			m_child.getInfo().position.x = posVec.getValue().x 
				+ m_child.getInfo().scale.x/2;
			m_child.getInfo().position.y = posVec.getValue().y
				+ m_child.getInfo().scale.y/2;
			m_child.getInfo().movement = movementBox.getSelection();
			m_child.getInfo().chargePolarity = parseInt(
				polarityBox.getSelection());
			m_child.getInfo().insulated = insulatedBox.getSelection() 
				== "Yes";
			m_child.getInfo().strong = strongBox.getSelection() 
				== "Yes";
			m_child.getInfo().bounds = new Vector.<UVec2>();
			var pA:UVec2 = trackPos1.getValue().getCopy();
			var pB:UVec2 = trackPos2.getValue().getCopy();
			m_child.getInfo().bounds.push(pA, pB);
			m_child.reinit();
		}
	}
}
