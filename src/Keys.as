package {
	import flash.events.Event;
	import flash.events.*;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.display.Sprite;
	
	// adapted from:
	// http://lassieadventurestudio.wordpress.com/2008/09/03/as3-key-isdown-behavior/
	
	public class Keys {
		
		public static function exitLevel():Boolean{
			return isKeyPressed(Keyboard.ESCAPE)||isKeyPressed(Keyboard.Q);
		}

		public static function resetLevel():Boolean{
			return isKeyPressed(Keyboard.R);
		}
		
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

			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
		}

 		public static function isKeyPressed(key:int):Boolean{
			return _keys.indexOf(key) > -1;
		}
		
		public static function any(... args):Boolean{
			for (var i:int = 0; i < args.length; i++)
        		if (isKeyPressed(args[i])) return true;
        	return false;
		}
	}
}
