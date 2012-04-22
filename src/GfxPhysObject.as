package {
	
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	import flash.display.Sprite;

	/** This keeps a graphics sprite updated with its physics counterpart */
	public class GfxPhysObject {

		private var m_physics:b2Body;
		private var m_graphics:Sprite;
		
	/** Constructor
				@param gfx The sprite to associate with this object 
				@param phys The physics object
				@remarks Either of these may be null, and may be swapped out
					using the getters and setters after construction */
		public function GfxPhysObject(gfx:Sprite = null, phys:b2Body = null) {
			m_physics = phys;
			m_graphics = gfx;
		}

		/** Getter for gfx object */
		public function getGraphics():Sprite {
			return m_graphics;
		}

		/** Setter for gfx object */
		public function setGraphics(gfx:Sprite):void {
			m_graphics = gfx;
			updateTransform();
		}

		/** Getter for phys object */
		public function getPhysics():Sprite {
			return m_graphics;
		}

		/** Setter for phys object */
		public function setPhysics(phys:b2Body):void {
			m_physics = phys;
			updateTransform();
		}

		/** Updates gfx object's transformation to match that of the gfx object */
		public function updateTransform():void {
			// if either is null, no need to update...
			if (m_graphics != null && m_physics != null) {
				var pos:b2Vec2 = m_physics.GetPosition();
				m_graphics.x = pos.x;
				m_graphics.y = pos.y;
				m_graphics.rotation = getAngle();
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
