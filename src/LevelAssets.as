package {

	public class LevelAssets {
		[Embed(source="../media/levels/Intro.json",  mimeType=
			"application/octet-stream")] private static const intro_lvl:Class;
		[Embed(source="../media/levels/Hole.json",  mimeType=
			"application/octet-stream")] private static const hole_lvl:Class;
		[Embed(source="../media/levels/Launch.json",  mimeType=
			"application/octet-stream")] private static const launch_lvl:Class;
		[Embed(source="../media/levels/Lifts.json",  mimeType=
			"application/octet-stream")] private static const lifts_lvl:Class;
		[Embed(source="../media/levels/Wall.json",  mimeType=
			"application/octet-stream")] private static const wall_lvl:Class;
		[Embed(source="../media/levels/Escalator.json",  mimeType=
			"application/octet-stream")] private static const escalator_lvl:Class;
		[Embed(source="../media/levels/Exchange.json",  mimeType=
			"application/octet-stream")] private static const exchange_lvl:Class;
		[Embed(source="../media/levels/Hang.json",  mimeType=
			"application/octet-stream")] private static const hang_lvl:Class;
		[Embed(source="../media/levels/Canyon2.json",  mimeType=
			"application/octet-stream")] private static const canyon2_lvl:Class;
		[Embed(source="../media/levels/Overworld.json",  mimeType=
			"application/octet-stream")] private static const overworld_lvl:Class;

		/**
		* Load all existing levels into a dictionary
		*/
		private static var associativeArray:Object;
		{
			associativeArray = new Object();
			associativeArray["intro"] = intro_lvl;
			associativeArray["hole"] = hole_lvl;
			associativeArray["launch"] = launch_lvl;
			associativeArray["lifts"] = lifts_lvl;
			associativeArray["wall"] = wall_lvl;
			associativeArray["escalator"] = escalator_lvl;
			associativeArray["exchange"] = exchange_lvl;
			associativeArray["hang"] = hang_lvl;
			associativeArray["canyon2"] = canyon2_lvl;
			associativeArray["overworld"] = overworld_lvl;
		}

		public static function getLevelSource(name:String):Class {
			return associativeArray[name];
		}
	}
}
