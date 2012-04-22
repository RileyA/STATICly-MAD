package {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import Game;

	/** A game state, this encapsulates some chunk of the game (e.g. a
		menu, a gameplay mode, etc...). */
	public class GameState extends Sprite {

		/** Reference to parent Game object */
		protected var m_game:Game;
		private var m_keys:Array;

		/** Constructor
			@param game reference to parent game */
		public function GameState(game:Game):void {
			m_game = game;
			m_keys = new Array();
			addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}

		/** Called at start of state */
		public function init():void {
		}

		/** Called at end of state */
		public function deinit():void {
		}

		/** Called every frame
			@param delta Time elapsed since last frame
			@return whether or not to continue the state or to move onto the next one */
		public function update(delta:Number):Boolean {
			return true;
		}

		/** Gets whether a given key is pressed
				@param key The desired keycode */
 		public function isKeyPressed(key:int):Boolean {
			return m_keys.indexOf(key) > -1;
		}

		/** Key down callback */
		private function handleKeyDown(evt:KeyboardEvent):void {
			if (m_keys.indexOf(evt.keyCode) == -1){
				m_keys.push(evt.keyCode);
			}
		}
		
		/** Key up callback */
		private function handleKeyUp(evt:KeyboardEvent):void {
			var i:int = m_keys.indexOf(evt.keyCode);
			if (i > -1){
				m_keys.splice(i, 1);
			}
		}
	}
}
