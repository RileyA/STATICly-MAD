package {
	import flash.display.Sprite;
	import starling.core.Starling;
	import flash.events.Event;

	[SWF(backgroundColor='#EEEEEE', frameRate='30', width='800', height='600')]

	public class Main extends Sprite {

		private var m_game:Game;
		private var m_starling:Starling;

		public function Main():void {
			super();
			m_starling = new Starling(Game, stage);
			m_starling.antiAliasing = .5;
			m_starling.start();
			//addEventListener(Event.ENTER_FRAME, update);
			Keys.init(this);
		}

		public function update(event:Event):void {
			m_game.update();
		}
	}
}




