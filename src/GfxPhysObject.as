package {
	
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;

	/** This keeps a graphics sprite updated with its physics counterpart */
	public class GfxPhysObject extends Sprite {

		protected var m_physics:b2Body;
		private static const PIXELS_PER_METER:Number = 30;
		
		/** Constructor
				@param phys The physics object
				@remarks Either of these may be null, and may be swapped out
					using the getters and setters after construction */
		public function GfxPhysObject(phys:b2Body = null) {
			m_physics = phys;
		}

		/** Getter for phys object */
		public function getPhysics():b2Body {
			return m_physics;
		}

		/** Setter for phys object */
		public function setPhysics(phys:b2Body):void {
			m_physics = phys;
			updateTransform();
		}

		/** Updates gfx object's transformation to match that of the gfx object */
		public function updateTransform():void {
			// if either is null, no need to update...
			if (m_physics != null) {
				var pos:b2Vec2 = m_physics.GetPosition();
				this.x = pos.x * 30.0;
				this.y = pos.y * 30.0;
				this.rotation = getAngle();
			} else {
				this.x = 0;
				this.y = 0;
				this.rotation = 0;
			}
		}

		/** Helper that gets angle of physics object in degrees 
				@return Physics object's angle in degrees or 0 if the 
					physics object is null */
		public function getAngle():Number {
			return m_physics == null ? 0.0 : m_physics.GetAngle() * 180.0/Math.PI;
		}
	}
}
