package {
	import cse481d.Logger;

	public class LoggerUtils {
		public static const NAME:String = "static";
		public static const GID:uint = 37;
		public static const SKEY:String = "6aeba66b031264a6c9b5c9e3ba55e90b";

		public static const CHARGE_WEAK_AID:uint = 1;
		public static const CHARGE_STRONG_AID:uint = 2;

		public static var l:Logger;

		public static function initLogger():void {
			if (!Config.logging) { return; }
			l = Logger.initialize(GID, NAME, SKEY, Config.CID, {"isdebug":true});
		}

		/** Return the QID of the specified level */
		public static function getQid(levelName:String):int {
			return LevelAssets.getLevelQid(levelName);
		}

		/** Log the charging of a weak block */
		public static function logChargeWeak(playerC:Number, blockC:Number):void {
			if (l == null) { return; }
			l.logAction(CHARGE_WEAK_AID, {"playerC":playerC, "blockC":blockC});
		}

		/** Log the charging of a strong block */
		public static function logChargeStrong(playerC:Number, blockC:Number):void {
			if (l == null) { return; }
			l.logAction(CHARGE_STRONG_AID, {"playerC":playerC, "blockC":blockC});
		}

		public static function logLevelStart(name:String, hash:Object):void {
			if (l == null) { return; }
			l.logLevelStart(getQid(name), hash);
		}

		public static function logLevelEnd(hash:Object):void {
			if (l == null) { return; }
			l.logLevelEnd(hash);
		}
	}
}
