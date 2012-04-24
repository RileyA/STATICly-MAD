package {
	/** Level information, to be loaded direct from JSON format */
	public class LevelInfo {
		public var title:String = "";
		public var player_x:Number;
		public var player_y:Number;
		public var gravity:Number;
		public var blocks:Vector.<BlockInfo> = new Vector.<BlockInfo>();
	}
}

