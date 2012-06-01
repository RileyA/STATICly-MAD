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
	import flash.geom.Point;

	/** A scalable containing a block, lets you take a block and scale
		it and drag it around and such */
	public class BlockProxy extends Scalable implements EditorProxy {
		
		private var m_child:Block;

		private var insulatedBox:EditorOption = null;
		private var strongBox:EditorOption = null;
		private var movementBox:EditorOption = null;
		private var polarityBox:EditorOption = null;
		private var posVec:EditorVectorOption = null;
		private var scaleVec:EditorVectorOption = null;
		private var trackPos1:EditorVectorOption = null;
		private var trackPos2:EditorVectorOption = null;
		private var surfaceLabel:TextField = null;
		private var actionLabel:TextField = null;
		private var surfaceElems:BlockElementForm = null;
		private var actionElems:BlockElementForm = null;

		public function BlockProxy(b:Block):void {
			m_child = b;
			var sc:UVec2 = b.getInfo().scale;
			super(b.x - sc.x * b.scaleX / 2, b.y -sc.y * b.scaleY / 2,
				sc.x * b.scaleX, sc.y * b.scaleY);
			super.setSnap(b.scaleX * snapTo);
			snapOffsetX = 0;
			snapOffsetY = 0;

			// don't ask... it fixes the reset bug
			gainFocus();
			loseFocus();
		}

		override public function reposition():void {
			super.reposition();

			var sc:UVec2 = m_child.getInfo().scale;

			// x,y + m_children[0].x,y are coords
			//var pos:UVec2 = new UVec2(x + m_children[0].x,
			//	y + m_children[0].y);

			/*var tmpPt:Point = new Point(m_children[0].x, m_children[0].y);
			tmpPt = m_children[0].localToGlobal(tmpPt);
			tmpPt = parent.parent.globalToLocal(tmpPt);
			var pos:UVec2 = new UVec2(tmpPt.x, tmpPt.y);
			pos.x /= m_child.scaleX;
			pos.y /= m_child.scaleY;
			//if (posVec) posVec.setValue(pos);
			pos.x += sc.x/2;
			pos.y += sc.y/2;
			m_child.setPosition(pos);
			m_child.clearVelocity();*/
			//if (scaleVec) scaleVec.setValue(sc);
		}

		override public function beginDrag():void {
			m_child.getPhysics().SetType(b2Body.b2_staticBody);
		}

		public function getBlock():Block {
			return m_child;
		}

		override public function endDrag():void {
			var world:b2World = m_child.getPhysics().GetWorld();
			var sc:UVec2 = m_child.getInfo().scale;
			var tmpPt:Point = new Point(m_children[0].x, m_children[0].y);
			//tmpPt = m_children[0].localToGlobal(tmpPt);
			//tmpPt = parent.globalToLocal(tmpPt);
			var pos:UVec2 = new UVec2(tmpPt.x + x, tmpPt.y + y);
			pos.x /= m_child.scaleX;
			pos.y /= m_child.scaleY;
			m_child.getPhysics().SetType(m_child.getBodyType());
			m_child.getInfo().scale.x = m_scalepx_x / m_child.scaleX;
			m_child.getInfo().scale.y = m_scalepx_y / m_child.scaleY;
			m_child.getInfo().position.x = pos.x + m_child.getInfo().scale.x / 2;
			m_child.getInfo().position.y = pos.y + m_child.getInfo().scale.y / 2;
			sc.x = m_scalepx_x / m_child.scaleX;
			sc.y = m_scalepx_y / m_child.scaleY;
			if (posVec) posVec.setValue(pos);
			if (scaleVec) scaleVec.setValue(sc);
			//reposition();
			m_child.reinit();
			//populateForm();
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

			posVec = new EditorVectorOption(
				"Pos: ", x / m_child.scaleX, y / m_child.scaleY);
			posVec.x = 4;
			posVec.y = 3;
			form.addChild(posVec);

			scaleVec = new EditorVectorOption(
				"Scale", m_child.getInfo().scale.x, m_child.getInfo().scale.y);
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

			function assignSelections(input:Vector.<String>, types:Vector.<String>, out:Vector.<int>,
				extras:Vector.<String>=null):void {
				for (var i:uint = 0; i < input.length; ++i) {
					var j:uint = 0;
					var strs:Array = input[i].split(",");
					var direct:String = strs[0];
					var objType:String = strs[1];
					if (direct == "up") j = 0;
					else if (direct == "down") j = 1;
					else if (direct == "left") j = 2;
					else if (direct == "right") j = 3;
					for (var k:uint = 0; k < types.length; ++k) {
						if (types[k] == objType) {
							out[j] = k;
							if (extras)
							{
								var extraStr:String = "";
								for (var m:uint = 2; m < strs.length; ++m) {
									if(strs[m] == "") break;
									extraStr += (m>2?",":"") + strs[m];
								}
								extras[j] = extraStr;
							}
							continue;
						}
					}
				}
			}

			var sopts:Vector.<String> = new Vector.<String>();
			var sxtras:Vector.<String> = null;//new Vector.<String>();
			var ssels:Vector.<int> = new Vector.<int>();
			sopts.push("None", "bcarpet", "rcarpet", "ground");
			//sxtras.push("", "", "", "");
			ssels.push(0,0,0,0);
			assignSelections(m_child.getInfo().surfaces, sopts, ssels, sxtras);
			
			surfaceElems = new BlockElementForm(sopts, ssels, sxtras);
			surfaceElems.x = 4;
			surfaceElems.y = 145;
			form.addChild(surfaceElems);

			var aopts:Vector.<String> = new Vector.<String>();
			var asels:Vector.<int> = new Vector.<int>();
			var axtras:Vector.<String> = new Vector.<String>();
			aopts.push("None", "exit", "entrance", "computer");
			axtras.push("", "", "", "");
			asels.push(0,0,0,0);
			assignSelections(m_child.getInfo().actions, aopts, asels, axtras);
			actionElems = new BlockElementForm(aopts, asels, axtras);
			actionElems.x = 4;
			actionElems.y = 220;
			form.addChild(actionElems);

			surfaceLabel = new TextField();
			surfaceLabel.defaultTextFormat = textFormat;
			surfaceLabel.text = "Surface Elements: ";
			surfaceLabel.x = 4;
			surfaceLabel.y = 130;
			surfaceLabel.width = 100;
			surfaceLabel.height = 12;
			surfaceLabel.selectable = false;
			form.addChild(surfaceLabel);

			actionLabel = new TextField();
			actionLabel.defaultTextFormat = textFormat;
			actionLabel.text = "Action Elements: ";
			actionLabel.x = 4;
			actionLabel.y = 205;
			actionLabel.width = 100;
			actionLabel.height = 12;
			actionLabel.selectable = false;
			form.addChild(actionLabel);

			insulatedBox.addEventListener(Event.CHANGE, handlePropChange);
			strongBox.addEventListener(Event.CHANGE, handlePropChange);
			polarityBox.addEventListener(Event.CHANGE, handlePropChange);
			movementBox.addEventListener(Event.CHANGE, handlePropChange);
			posVec.addEventListener(Event.CHANGE, handlePropChange);
			scaleVec.addEventListener(Event.CHANGE, handlePropChange);
			trackPos1.addEventListener(Event.CHANGE, handlePropChange);
			trackPos2.addEventListener(Event.CHANGE, handlePropChange);
			surfaceElems.addEventListener(Event.CHANGE, handlePropChange);
			actionElems.addEventListener(Event.CHANGE, handlePropChange);
		}

		public function updateForm():void {
			// TODO
		}

		public function getCaption():String {
			return "Block";
		}

		public function handlePropChange(e:Event):void {
			if (e.target != posVec && e.target != scaleVec) {
				endDrag();
			}
			x = posVec.getValue().x * m_child.scaleX;
			y = posVec.getValue().y * m_child.scaleY;
			reposition();
			m_child.getInfo().scale.x = scaleVec.getValue().x;
			m_child.getInfo().scale.y = scaleVec.getValue().y;
			forceScale(m_child.getInfo().scale.x * m_child.scaleX, 
				m_child.getInfo().scale.y * m_child.scaleY);
			//m_child.getInfo().position.x = posVec.getValue().x;
			//	+ m_child.getInfo().scale.x/2;
			//m_child.getInfo().position.y = posVec.getValue().y;
			//	+ m_child.getInfo().scale.y/2;
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

			m_child.getInfo().actions = new Vector.<String>;
			m_child.getInfo().surfaces = new Vector.<String>;

			var temp:Vector.<String> = new Vector.<String>;
			temp.push("up", "down", "left", "right");
			for (var i:uint = 0; i < 4; ++i) {
				if (actionElems.options[actionElems.selections[i]] != "None") {
					var extraInfo:String = "";
					if (actionElems.extras != null && actionElems.extras[i] != "")
						extraInfo += "," + actionElems.extras[i];
					else if (actionElems.extras != null)
						extraInfo = ",";
					m_child.getInfo().actions.push(temp[i] + ","
						+ actionElems.options[actionElems.selections[i]] + extraInfo);
				}
			}
			for (i = 0; i < 4; ++i) {
				if (surfaceElems.options[surfaceElems.selections[i]] != "None") {
					m_child.getInfo().surfaces.push(temp[i] + ","
						+ surfaceElems.options[surfaceElems.selections[i]]);
				}
			}

			m_child.getInfo().bounds.push(pA, pB);
			m_child.reinit();
		}
	}
}
