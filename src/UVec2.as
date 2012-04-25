package {

	import Box2D.Common.Math.b2Vec2;

	/** A universal vector, contains components in each unit, easily loadable
		via JSON and then converted to metric/whatever */
	public class UVec2 {
		// meters
		public var x:Number = 0;
		public var y:Number = 0;
		// relative component
		public var x_rel:Number = 0;
		public var y_rel:Number = 0;
		// pixels
		public var x_px:Number = 0;
		public var y_px:Number = 0;

		public function UVec2(x_meters:Number = 0, y_meters:Number = 0):void {
			x = x_meters;
			y = y_meters;
		}

		/** helper that converts everything into plain meters
				@param pxPerMeter Pixels per meter
				@param width Width in meters of parent 
				@param height Height in meters of parent */
		public function makeMetric(pxPerMeter:Number, width:Number, 
			height:Number):void {
			x += x_px / pxPerMeter;
			y += y_px / pxPerMeter;
			x += x_rel * width;
			x += y_rel * height;
			x_px = y_px = x_rel = y_rel = 0;
		}

		/** Converts metric component into a box2d vector */
		public function toB2Vec2():b2Vec2 {
			return new b2Vec2(x, y);
		}

		/** Returns a copy in metric */
		public function getMetric(pxPerMeter:Number, width:Number, 
			height:Number):UVec2 {
			var out:UVec2 = getCopy();
			out.makeMetric(pxPerMeter, width, height);
			return out;
		}

		/** Returns a copy of this vector */
		public function getCopy():UVec2 {
			var out:UVec2 = new UVec2(x, y);
			out.x_px = x_px;
			out.y_px = y_px;
			out.x_rel = x_rel;
			out.y_rel = y_rel;
			return out;
		}
	}
}
