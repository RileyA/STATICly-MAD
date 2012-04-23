package {

	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	/** A set of constants and helpers for box2d stuffs */
	public class PhysicsUtils {
		
		public static const PIXELS_PER_METER:Number = 30;
		public static const FOOT_SENSOR_ID:uint = 1;

		/** Meters -> Pixels
			@param v Vector to convert */
		public static function fromPixels(v:b2Vec2):b2Vec2 {
			return new b2Vec2(v.x / PIXELS_PER_METER, v.y / PIXELS_PER_METER);
		}

		/** Meters -> Pixels
			@param v Vector to convert */
		public static function toMeters(v:b2Vec2):b2Vec2 {
			return fromPixels(v);
		}

		/** Pixels -> Meters
			@param v Vector to convert */
		public static function toPixels(v:b2Vec2):b2Vec2 {
			return new b2Vec2(v.x * PIXELS_PER_METER, v.y * PIXELS_PER_METER);
		}

		/** Pixels -> Meters
			@param v Vector to convert */
		public static function fromMeters(v:b2Vec2):b2Vec2 {
			return toPixels(v);
		}
	}
}
