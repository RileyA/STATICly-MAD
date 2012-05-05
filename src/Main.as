package {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;

	import Game;
	import MenuState;

	[SWF(backgroundColor='#000000', frameRate='30', width='800', height='600')]

	public class Main extends Sprite {

		private var m_game:Game;

		public function Main():void{
			Keys.init(this);
			m_game = new Game(this);
			m_game.addState(new MenuState(m_game));
			m_game.addState(new OverworldState(m_game));
			m_game.addState(new LevelState(m_game, "intro"));
			addEventListener(Event.ENTER_FRAME, update);
		}

		public function update(event:Event):void {
			m_game.update();
		}
	}
}




