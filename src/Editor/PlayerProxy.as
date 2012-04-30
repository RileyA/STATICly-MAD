package Editor {
	import flash.display.*;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;

	/** A scalable containing a block, lets you take a block and scale
		it and drag it around and such */
	public class PlayerProxy extends Draggable implements EditorProxy {
		
		private var m_child:Player;
		private static var posX:TextField = new TextField();
		private static var posY:TextField = new TextField();
		private static var posLabel:TextField = new TextField();

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

		override public function beginDrag():void { m_child.getPhysics().SetType(b2Body.b2_staticBody);
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

		public function populateForm(form:Sprite):void {
			var textFormat:TextFormat = new TextFormat("Sans", 8, 0x000000);
			posX.defaultTextFormat = textFormat;
			posX.text = Number(x / m_child.scaleX).toFixed(4);
			posX.x = 53;
			posX.y = 4;
			posX.width = 45;
			posX.height = 12;
			posX.type = TextFieldType.INPUT;
			posX.border = true;
			posX.alpha = 1;
			posX.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			posX.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			posX.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(posX);

			posY = new TextField();
			posY.defaultTextFormat = textFormat;
			posY.text = Number(y / m_child.scaleY).toFixed(4);
			posY.x = 100;
			posY.y = 4;
			posY.width = 45;
			posY.height = 12;
			posY.type = TextFieldType.INPUT;
			posY.border = true;
			posY.alpha = 1;
			posY.addEventListener(KeyboardEvent.KEY_UP, EditorMenu.onKey);
			posY.addEventListener(KeyboardEvent.KEY_DOWN, EditorMenu.onKey);
			posY.addEventListener(Event.CHANGE, handlePropChange);
			form.addChild(posY);

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
		}

		public function handlePropChange(e:Event):void {
			x = parseFloat(posX.text) * m_child.scaleX;
			y = parseFloat(posY.text) * m_child.scaleY;
			reposition();
		}

		public function getCaption():String {
			return "Player";
		}

		public function updateForm():void {
			posX.text = Number(x / m_child.scaleX).toFixed(4);
			posY.text = Number(y / m_child.scaleY).toFixed(4);
		}
	}
}
