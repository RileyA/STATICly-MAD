package  
{
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	
	public class SoundManager {
		
		private static var allSounds:Dictionary;
		private static const soundPaths:Array = ["../media/sounds/jump1.mp3",
												"../media/sounds/jump2.mp3",
												"../media/sounds/jump3.mp3",
												"../media/sounds/zap1.wav",
												"../media/sounds/zap2.wav",
												"../media/sounds/zap3.wav",
												"../media/sounds/zap4.wav",
												];
		
		public static function init():void {
			allSounds = new Dictionary();
			var s:Sound;
			for (var index in soundPaths) {
				s = new Sound(); 
				s.addEventListener(Event.COMPLETE, onSoundLoaded);
				var req:URLRequest = new URLRequest(soundPaths[index]);
				s.load(req);
			}
			//s = new Sound(); 
			//s.addEventListener(Event.COMPLETE, onSoundLoaded);
			//var req:URLRequest = new URLRequest("../media/sounds/jump1.mp3");
			//s.load(req);
			
		}
		
		private static function onSoundLoaded(e:Event):void {
			var localSound:Sound = Sound(e.target);
			var name:String = localSound.url;
			name = name.replace(/.*\//, "");
			name = name.replace(/\..*/, "");
			//trace(name);
			allSounds[name] = localSound;
			
		}
		
		public static function play(name:String, loops:int = 0):void {
			//trace(name);
			var localSound:Sound = Sound(allSounds[name]);
			if (localSound != null) {
				//trace("found sound");
				localSound.play(0, loops);
			}
		}
		
	}

}