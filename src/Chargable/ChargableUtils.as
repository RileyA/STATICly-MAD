package Chargable {
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

	public class ChargableUtils {
		// Defines the numeric charge value for blue, red, or no charge.
		public static const CHARGE_BLUE:int = +1;
		public static const CHARGE_NONE:int = 0;
		public static const CHARGE_RED:int = -1;

		private static const COLOR_TRANS_BLUE:ColorTransform = new ColorTransform(.2,.2,1.1);
		private static const COLOR_TRANS_NONE:ColorTransform = new ColorTransform();
		private static const COLOR_TRANS_RED:ColorTransform = new ColorTransform(1.1,.2,.2);
		{
			COLOR_TRANS_RED.redOffset=50;
			COLOR_TRANS_BLUE.blueOffset=50;
		}

		public static function matchColorToPolarity(sprite:Sprite, polarity:int):void {
			switch (polarity) {
			case CHARGE_BLUE:
				sprite.transform.colorTransform = COLOR_TRANS_BLUE;
				break;
			case CHARGE_RED:
				sprite.transform.colorTransform = COLOR_TRANS_RED;
				break;
			default:
				sprite.transform.colorTransform = COLOR_TRANS_NONE;
				break;
			}
		}
	}
}
