package Particle {

	public class ParticleAffector {
		public static const PA_FORCE:String = "FORCE";
		public static const PA_FADE:String = "FADE";

		public var type:String;

		// force
		public var force_x:Number = 0.0;
		public var force_y:Number = 0.0;

		// fade
		public var fade_start:Number = 1.0;
		public var fade_end:Number = 1.0;
		public var fade_duration:Number = 1.0;

		public function ParticleAffector():void {
			//...
		}
	}
}
