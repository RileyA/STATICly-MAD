package {
	/** Level information, to be loaded direct from JSON format */
	public class LevelInfo {
		public var title:String = "";
		public var targetTime:Number = 60;
		public var playerPosition:UVec2 = new UVec2;
		public var levelSize:UVec2 = new UVec2(27, 20);
		public var gravity:UVec2 = new UVec2(0, 9.8);
		public var blocks:Vector.<BlockInfo> = new Vector.<BlockInfo>();
		public var hints:Vector.<HintInfo> = new Vector.<HintInfo>();
	}
}

