package {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import BlockDemoState;

	/** Simple placeholder menu state with a button that starts another state */
	public class MenuState extends GameState {

		private var m_done:Boolean;

		public function MenuState(game:Game):void {
			super(game);
			m_done = false;
		}

		override public function init():void {
			var format:TextFormat = new TextFormat("Sans", 30, 0x000000);
			format.align = "center";
			var hello_text:TextField = new TextField();
			hello_text.width = 800;
			hello_text.height = 100;
			hello_text.x = 0;
			hello_text.y = 150;
			hello_text.defaultTextFormat = format;
			hello_text.text = "STATICly MAD! Click here for hello world...";
			hello_text.selectable = false;
			hello_text.addEventListener(MouseEvent.MOUSE_UP, clickedPlay);
			addChild(hello_text);

			var block_text:TextField = new TextField();
			block_text.width = 600;
			block_text.height = 100;
			block_text.x = 100;
			block_text.y = 300;
			block_text.defaultTextFormat = format;
			block_text.text = "Or click here for physics demo!";
			block_text.selectable = false;
			block_text.addEventListener(MouseEvent.MOUSE_UP, clickedDemo);
			addChild(block_text);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			return !m_done;
		}

		private function clickedPlay(event:MouseEvent):void {
			if (!m_done) {
				m_done = true;
				m_game.addState(new HelloState(m_game));
			}
		}

		private function clickedDemo(event:MouseEvent):void {
			if (!m_done) {
				m_done = true;
				m_game.addState(new BlockDemoState(m_game));
			}
		}
	}
}