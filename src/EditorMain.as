package {
	/*import flash.display.Sprite;
	import starling.core.Starling;
	
	import flash.display.Shape;
	import flash.events.Event;

	import Game;*/
	import Editor.EditorState;

	import flash.display.Sprite;
	import starling.core.Starling;
	import flash.events.Event;
	import starling.events.Event;
	import Config;

	[SWF(backgroundColor='#ffffff', frameRate='30', width='800', height='600')]

	public class EditorMain extends Sprite {

		private var m_game:Game;
		private var m_starling:Starling;

		public function EditorMain():void{
			Main.stage=stage;
			super();
			m_starling = new Starling(EditorGame, stage);
			m_starling.antiAliasing = 0; // 0 to 16. 0=fast, 2=pretty good looking
			m_starling.showStats=Config.debug;
			m_starling.start();			
			addEventListener(flash.events.Event.ENTER_FRAME, update);
			Keys.init(this);

			SoundManager.init();
		}

		public function update(event:flash.events.Event):void {
			if (m_game == null) {
				m_game = Game(m_starling.stage.getChildAt(0));
			}
			m_game.update();
		}
	}
}




