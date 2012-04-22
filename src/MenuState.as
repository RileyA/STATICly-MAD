package {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

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
			var m_hello_text:TextField = new TextField();
			m_hello_text.width = 600;
			m_hello_text.height = 100;
			m_hello_text.x = 100;
			m_hello_text.y = 150;
			m_hello_text.defaultTextFormat = format;
			m_hello_text.text = "STATICly MAD! Click here to play.";
			m_hello_text.selectable = false;
			m_hello_text.addEventListener(MouseEvent.MOUSE_UP, clickedPlay);
			addChild(m_hello_text);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			return !m_done;
		}

		public function clickedPlay(event:MouseEvent):void {
			if (!m_done) {
				m_done = true;
				m_game.addState(new HelloState(m_game));
			}
		}
	}
}
