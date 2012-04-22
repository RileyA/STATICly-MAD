package {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;

	import Game;
	import MenuState;

	[SWF(backgroundColor='#ffffff', frameRate='30', width='800', height='600')]

	public class Main extends Sprite {

		private var m_game:Game;

		public function Main():void{
			m_game = new Game(this);
			m_game.addState(new MenuState(m_game));
			addEventListener(Event.ENTER_FRAME, update);
		}

		public function update(event:Event):void {
			m_game.update();
		}
	}
}




