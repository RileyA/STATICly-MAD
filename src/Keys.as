package {
	import flash.events.Event;
	import flash.events.*;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.display.Sprite;
	
	// adapted from:
	// http://lassieadventurestudio.wordpress.com/2008/09/03/as3-key-isdown-behavior/
	
	public class Keys {
		
		public static var ExitLevel:int=Keyboard.ESCAPE;
		
		private static var _keys:Array = new Array();

		public static function init(main:Sprite):void{ 

			function handleKeyDown(evt:KeyboardEvent):void{
				if (_keys.indexOf(evt.keyCode) == -1){
					_keys.push(evt.keyCode);
				}
			}

			function handleKeyUp(evt:KeyboardEvent):void{
				var i:int = _keys.indexOf(evt.keyCode);

				if (i > -1){
					_keys.splice(i, 1);
				}
			}

			main.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			main.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}

 		public static function isKeyPressed(key:int):Boolean{
			return _keys.indexOf(key) > -1;
		}
	}
}
