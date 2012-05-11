package {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;

	import Game;

	[SWF(backgroundColor='#050505', frameRate='30', width='800', height='600')]

	public class Main extends Sprite {

		private var m_game:Game;

		public function Main():void{
			Keys.init(this);
			m_game = new Game(this);
			var overworldState:OverworldState=m_game.getOverworld("DischargeLab");
			m_game.addState(overworldState);
			m_game.addState(new LevelState(m_game, "Intro", overworldState));
			addEventListener(Event.ENTER_FRAME, update);
		}

		public function update(event:Event):void {
			m_game.update();
		}
	}
}




