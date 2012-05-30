package  
{
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	
	public class SoundManager {
		
		private static var allSounds:Dictionary;
		
		public static function init():void {
			allSounds = new Dictionary();
			var s:Sound = new Sound(); 
			s.addEventListener(Event.COMPLETE, onSoundLoaded); 
			var req:URLRequest = new URLRequest("../media/sounds/jump1.mp3"); 
			s.load(req);
			
		}
		
		private static function onSoundLoaded(e:Event):void {
			var localSound:Sound = Sound(e.target);
			var name:String = localSound.url;
			name = name.replace(".*/", "");
			name = name.replace("\..*", "");
			allSounds[name] = localSound;
		}
		
		public static function play(name:String, loops:int = 0):void {
			var localSound:Sound = Sound(allSounds[name]);
			if(localSound != null)
				localSound.play(0, loops);
		}
		
	}

}