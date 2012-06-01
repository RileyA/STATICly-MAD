package  
{
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	
	public class SoundManager {
		
		//[Embed(source = )] 
        //private static const music:Class;
		
		private static var muted:Boolean;
		private static var allSounds:Dictionary;
		private static var playing:Dictionary;
		private static var musicPlayback:SoundChannel;
		private static var pausePoint:Number;
		//private static const soundPaths:Array = ["../media/sounds/jump1.mp3",
												//"../media/sounds/jump2.mp3",
												//"../media/sounds/zap1.mp3",
												//"../media/sounds/zap2.mp3",
												//"../media/sounds/zap3.mp3",
												//"../media/sounds/zap4.mp3",
												//];
		[Embed(source = "../media/sounds/jump1.mp3")]
		private static var jump1:Class;
		[Embed(source = "../media/sounds/jump2.mp3")]
		private static var jump2:Class;
		[Embed(source = "../media/sounds/zap1.mp3")]
		private static var zap1:Class;
		[Embed(source = "../media/sounds/zap2.mp3")]
		private static var zap2:Class;
		[Embed(source = "../media/sounds/zap3.mp3")]
		private static var zap3:Class;
		[Embed(source = "../media/sounds/zap4.mp3")]
		private static var zap4:Class;
		[Embed(source = "../media/sounds/bgMusic.mp3")]
		private static var music:Class;
		
		public static function init():void {
			allSounds = new Dictionary();
			playing = new Dictionary();
			muted = false;
			//var s:Sound;
			//var req:URLRequest;
			//for (var index:String in soundPaths) {
				//s = new Sound(); 
				//s.addEventListener(Event.COMPLETE, onSoundLoaded);
				//req = new URLRequest(soundPaths[int(index)]);
				//s.load(req);
			//}
			//s = new Sound(); 
			//s.addEventListener(Event.COMPLETE, onMusicLoaded);
			//req = new URLRequest("../media/sounds/bgMusic.mp3");
			//s.load(req);
			initSound(jump1, "jump1");
			initSound(jump2, "jump2");
			initSound(zap1, "zap1");
			initSound(zap2, "zap2");
			initSound(zap3, "zap3");
			initSound(zap4, "zap4");
			musicLoaded(music);
		}
		
		private static function initSound(b:Class, name:String):void {
			var localSound:Sound = (new b) as Sound;
			//var name:String = localSound.url;
			//name = name.replace(/.*\//, "");
			//name = name.replace(/\..*/, "");
			allSounds[name] = localSound;
		}
		
		private static function musicLoaded(b:Class):void {
			var localSound:Sound = (new b) as Sound;
			allSounds["bgMusic"] = localSound;
			musicPlayback = localSound.play(0, int.MAX_VALUE);
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
			pausePoint = musicPlayback.position;
			musicPlayback.stop();
			muted = true;
		}
		
		public static function unmute():void {
			musicPlayback = Sound(allSounds["bgMusic"]).play(pausePoint, int.MAX_VALUE);
			muted = false;
		}
		
	}

}