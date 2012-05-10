package {
	import flash.display.Shape;
	import starling.events.*;
	import starling.text.TextField;
	import Editor.*;

	/** Simple placeholder menu state with a button that starts another state */
	public class MenuState extends GameState {

		protected var m_done:Boolean;

		public function MenuState(game:Game):void {
			super(game);
			m_done = false;
		}

		override public function init():void {
			//TODO
			var hello_text:TextField = new TextField(800,100,"STATICly MAD! Click here for hello world...", "Verdana", 30);
			hello_text.x = 0;
			hello_text.y = 150;
			hello_text.hAlign = "center";
			hello_text.addEventListener(TouchEvent.TOUCH, clickedPlay);
			addChild(hello_text);
			
			var block_text:TextField = new TextField(800,100,"Or click here for the Overworld!", "Verdana", 30);
			block_text.x = 0;
			block_text.y = 150;
			block_text.hAlign = "center";
			block_text.addEventListener(TouchEvent.TOUCH, clickedDemo);
			addChild(block_text);
			
			//var editor_text:TextField = new TextField();
			//editor_text.width = 600;
			//editor_text.height = 100;
			//editor_text.x = 100;
			//editor_text.y = 500;
			//editor_text.defaultTextFormat = format;
			//editor_text.text = "Or click here for the level editor!";
			//editor_text.selectable = false;
			//editor_text.addEventListener(MouseEvent.MOUSE_UP, clickedEditor);
			//addChild(editor_text);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			return !m_done;
		}

		private function clickedPlay(event:TouchEvent):void {
			if (!m_done) {
				m_game.addState(new HelloState(m_game));
			}
		}
		
		private function clickedDemo(event:TouchEvent):void {
			if (!m_done) {
				m_game.addState(new OverworldState(m_game));
			}
		}
		
		//private function clickedEditor(event:MouseEvent):void {
			//if (!m_done) {
				//m_game.addState(new Editor.EditorState(m_game));
			//}
		//}
	}
}
