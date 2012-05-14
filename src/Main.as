package {
	import flash.display.Sprite;
	import starling.core.Starling;
	import flash.events.Event;
	import starling.events.Event;
	import Config;

	[SWF(backgroundColor='#050505', frameRate='30', width='800', height='600')]

	public class Main extends Sprite {

		private var m_game:Game;
		private var m_starling:Starling;

		public function Main():void {
			super();
			m_starling = new Starling(Game, stage);
			m_starling.antiAliasing = 0; // 0 to 16. 0=fast, 2=pretty good looking
			m_starling.showStats=Config.debug;
			m_starling.start();			
			addEventListener(flash.events.Event.ENTER_FRAME, update);
			Keys.init(this);
			
			//m_game = new Game(this);
			//var overworldState:OverworldState=m_game.getOverworld("DischargeLab");
			//m_game.addState(overworldState);
			//m_game.addState(new LevelState(m_game, "Intro", overworldState));
			//addEventListener(Event.ENTER_FRAME, update);
		}

		public function update(event:flash.events.Event):void {
			if (m_game == null) {
				m_game = Game(m_starling.stage.getChildAt(0));
			}
			m_game.update();
		}
	}
}




