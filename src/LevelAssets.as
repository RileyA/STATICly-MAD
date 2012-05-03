package {

	public class LevelAssets {
		[Embed(source="../media/levels/Intro.json",  mimeType=
			"application/octet-stream")] private static const intro_lvl:Class;
		[Embed(source="../media/levels/Canyon2.json",  mimeType=
			"application/octet-stream")] private static const canyon2_lvl:Class;
		[Embed(source="../media/levels/Hole.json",  mimeType=
			"application/octet-stream")] private static const hole_lvl:Class;
		[Embed(source="../media/levels/Escalator.json",  mimeType=
			"application/octet-stream")] private static const escalator_lvl:Class;
//		[Embed(source="../media/levels/overworld.json",  mimeType=
//			"application/octet-stream")] private static const overworld_lvl:Class;

		/**
		* Load all existing levels into a dictionary
		*/
		private static var associativeArray:Object;
		{
			associativeArray = new Object();
			associativeArray["intro"] = intro_lvl;
			associativeArray["canyon2"] = canyon2_lvl;
			associativeArray["hole"] = hole_lvl;
			associativeArray["escalator"] = escalator_lvl;
//			associativeArray["overworld"] = overworld_lvl;
		}

		public static function getLevelSource(name:String):Class {
			return associativeArray[name];
		}
	}
}
