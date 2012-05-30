package  
{
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	
	public class SoundManager {
		
		private static var muted:Boolean;
		private static var allSounds:Dictionary;
		private static var playing:Dictionary;
		private static const soundPaths:Array = ["../media/sounds/jump1.mp3",
												"../media/sounds/jump2.mp3",
												"../media/sounds/zap1.mp3",
												"../media/sounds/zap2.mp3",
												"../media/sounds/zap3.mp3",
												"../media/sounds/zap4.mp3",
												];
		
		public static function init():void {
			allSounds = new Dictionary();
			playing = new Dictionary();
			muted = false;
			var s:Sound;
			for (var index:String in soundPaths) {
				s = new Sound(); 
				s.addEventListener(Event.COMPLETE, onSoundLoaded);
				var req:URLRequest = new URLRequest(soundPaths[int(index)]);
				s.load(req);
			}
		}
		
		private static function onSoundLoaded(e:Event):void {
			var localSound:Sound = Sound(e.target);
			var name:String = localSound.url;
			name = name.replace(/.*\//, "");
			name = name.replace(/\..*/, "");
			allSounds[name] = localSound;
			
		}
		
		public static function play(name:String, loops:int = 0):void {
			if(!muted) {
				var localSound:Sound = Sound(allSounds[name]);
				if (localSound != null) {
					playing[localSound] = localSound.play(0, loops);
				}
			}
		}
		
		public static function toggle():Boolean {
			if (muted) {
				unmute();
				return true;
			} else {
				mute();
				return false;
			}
		}
		
		public static function mute():void {
			for (var key:Object in  playing) {
				SoundChannel(playing[key]).stop();
			}
			muted = true;
		}
		
		public static function unmute():void {
			muted = false;
		}
		
	}

}