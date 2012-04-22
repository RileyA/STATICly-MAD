package {
	import flash.display.Sprite;
	import flash.display.Shape;
	import Game;

	public class GameState extends Sprite {

		/** Reference to parent Game object */
		protected var m_game:Game;
		
		/** Constructor
			@param game reference to parent game */
		public function GameState(game:Game):void {
			m_game = game;
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
	}
}
