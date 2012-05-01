package {
	/** Scoring information for a level, including timing and computer-killing. */
	public class ScoreInfo {
		public var title:String;
		public var playerTime:Number;
		public var targetTime:Number;
		public var playerComps:int;
		public var targetComps:int;

		public function ScoreInfo(title:String, targetTime:Number, targetComps:int):void {
			this.title = title;
			this.targetTime = targetTime;
			this.targetComps = targetComps;
			playerTime = 0;
			playerComps = 0;
		}
	}
}
