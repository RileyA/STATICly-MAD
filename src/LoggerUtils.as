package {
	import cse481d.Logger;

	public class LoggerUtils {
		public static const NAME:String = "static";
		public static const GID:uint = 37;
		public static const SKEY:String = "6aeba66b031264a6c9b5c9e3ba55e90b";

		public static const CHARGE_BLOCK_AID:uint = 1;
		public static const RESET_AID:uint = 2;
		public static const QUIT_AID:uint = 3;

		public static var l:Logger;
		private static var inLevel:Boolean;

		public static function initLogger():void {
			if (!Config.logging) { return; }
			l = Logger.initialize(GID, NAME, SKEY, Config.CID, {"isdebug":Config.debug});
			inLevel = false;
		}

		/** Return the QID of the specified level */
		public static function getQid(levelName:String):int {
			return LevelAssets.getLevelQid(levelName);
		}

		/** Log the charging of a block */
		public static function logChargeBlock(playerC:Number, blockC:Number, isStrong:Boolean):void {
			if (l == null || !inLevel) { return; }
			var strong:int = (isStrong) ? 1 : 0;
			l.logAction(CHARGE_BLOCK_AID, {"ch_p":playerC, "ch_b":blockC, "str_b":strong});
		}

		public static function logResetLevel():void {
			if (l == null || !inLevel) { return; }
			l.logAction(RESET_AID, null);
		}

		public static function logQuitLevel():void {
			if (l == null || !inLevel) { return; }
			l.logAction(QUIT_AID, null);
		}

		public static function logLevelStart(name:String, hash:Object):void {
			if (l == null || inLevel) { return; }
			l.logLevelStart(getQid(name), hash);
			inLevel = true;
		}

		public static function logLevelEnd(hash:Object):void {
			if (l == null || !inLevel) { return; }
			l.logLevelEnd(hash);
			inLevel = false;
		}
	}
}
