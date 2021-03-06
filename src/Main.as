package {
	import flash.display.Sprite;
	import starling.core.Starling;
	import flash.events.Event;
	import Config;
	
	[Frame(factoryClass="Preloader")]
	[SWF(backgroundColor='#050505', frameRate='30', width='800', height='600')]

	public class Main extends Sprite {

		private var m_game:Game;
		private var m_starling:Starling;
		public static var stage:flash.display.Stage;
		
		public function Main(stage:flash.display.Stage):void {
			Kong.init(stage);
			
			Main.stage=stage;
			super();
			m_starling = new Starling(Game, stage);
			m_starling.antiAliasing = 4; // 0 to 16. 0=fast, 2=pretty good looking
			m_starling.showStats=Config.debug;
			m_starling.start();			
			addEventListener(flash.events.Event.ENTER_FRAME, update);
			Keys.init(this);
			
			SoundManager.init();
		}

		public function update(event:Event):void {
			if (m_game == null) {
				m_game = Game(m_starling.stage.getChildAt(0));
			}
			m_game.update();
		}
	}
}




