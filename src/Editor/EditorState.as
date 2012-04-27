package Editor {

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import GameState;

	/** A basic level */
	public class EditorState extends GameState {

		private var m_blocks:Vector.<BlockProxy>;
		private var m_info:LevelInfo;

		public function EditorState(game:Game):void {
			super(game);
		}

		override public function init():void {
			m_blocks = new Vector.<BlockProxy>;
			var block_text:TextField = new TextField();
			block_text.width = 600;
			block_text.height = 500;
			block_text.x = 5;
			block_text.y = 5;
			block_text.text = "Testing Level Editor";
			block_text.selectable = false;
			addChild(block_text);
			addChild(new Scalable(50,50,50,50));
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			return true;
		}
	}
}
