package {
	import flash.display.Sprite;
	import starling.core.Starling;
	
	import flash.display.Shape;
	import flash.events.Event;

	import Game;
	import Editor.EditorState;

	[SWF(backgroundColor='#ffffff', frameRate='30', width='800', height='600')]

	public class EditorMain extends Sprite {

		private var m_game:Game;
		private var m_starling:Starling;

		public function EditorMain():void{
			Keys.init(this);
			m_game = new Game(this);
			m_game.addState(new EditorState(m_game));
			addEventListener(Event.ENTER_FRAME, update);
			
			m_starling = new Starling(m_game, stage);
			mStarling.antiAliasing = .5;
			mStarling.start();
		}

		public function update(event:Event):void {
			m_game.update();
		}
	}
}




