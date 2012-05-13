package {
	import flash.display.Bitmap;
	import starling.textures.Texture;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import Game;

	/** A game state, this encapsulates some chunk of the game (e.g. a
		menu, a gameplay mode, etc...). */
	public class GameState extends Sprite {

		/** Reference to parent Game object */
		protected var m_game:Game;
		public var initialized:Boolean = false;

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
			return true; // Generic GameState has no reason to exist
		}

		/** Called when a state is being "paused" and a new state is 
			being pushed onto the stack */
		public function suspend():void {
		}

		/** Called when the state above this is popped and this one is resumed */
		public function resume():void {
		}
		
		protected function tileBG(Background:Class):void {
			var bgBitmap:Bitmap = new Background();
			var texture:Texture = Texture.fromBitmap(bgBitmap);
			var bgImage:Image;
			var bgSprite:Sprite = new Sprite();
			var i:int = 0;
			var j:int = 0;
			
			while (i < 800) {
				while (j < 600) {
					//trace(i, j);
					bgImage = new Image(texture);
					bgImage.x = i;
					bgImage.y = j;
					bgSprite.addChild(bgImage);
					j += bgImage.height;
				}
				//trace(bgImage.width, bgImage.height);
				i += bgImage.width;
				j = 0;
			}
			bgSprite.flatten();
			addChild(bgSprite);
		}

	}
}
