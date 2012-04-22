package {
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/** A simple example state, displays hello world and exits after
		5 seconds */
	public class HelloState extends GameState {

		private var m_timer:Number;
		private var m_hello_text:TextField;

		public function HelloState(game:Game):void {
			super(game);
			m_timer = 5.0;
		}

		override public function init():void {
			var format:TextFormat = new TextFormat("Sans", 30, 0x000000);
			format.align = "center";
			m_hello_text = new TextField();
			m_hello_text.width = 600;
			m_hello_text.height = 100;
			m_hello_text.x = 100;
			m_hello_text.y = 150;
			m_hello_text.defaultTextFormat = format;
			m_hello_text.text = "Hello, World!";
			addChild(m_hello_text);
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			m_timer -= delta;
			m_hello_text.text = "Hello, World!\nGoing back to menu in: "
				+ m_timer.toFixed(2) + "s";
			if (m_timer > 0.0) {
				return true;
			} else {
				m_game.addState(new MenuState(m_game));
				return false;
			}
		}
	}
}
