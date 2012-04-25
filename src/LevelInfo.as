package {
	/** Level information, to be loaded direct from JSON format */
	public class LevelInfo {
		public var title:String = "";
		public var playerPosition:UVec2 = new UVec2;
		public var levelSize:UVec2 = new UVec2(26.666, 20);
		public var gravity:UVec2 = new UVec2(0, 9.8);
		public var blocks:Vector.<BlockInfo> = new Vector.<BlockInfo>();
	}
}
