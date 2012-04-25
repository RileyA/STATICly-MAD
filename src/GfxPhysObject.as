package {
	
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;

	import flash.display.Sprite;
	import flash.display.DisplayObject;

	/** This keeps a collection of graphics sprites updated with 
		their physics counterparts */
	public class GfxPhysObject extends Sprite {

		protected var m_physics:b2Body;
		
		/** Constructor
				@param physics The physics object */
		public function GfxPhysObject(phys:b2Body = null) {
			m_physics = phys;
		}

		/** Getter for physics object */
		public function getPhysics():b2Body {
			return m_physics;
		}

		/** Setter for physics object */
		public function setPhysics(phys:b2Body):void {
			m_physics = phys;
		}

		/** Updates gfx object's transformation to match that of 
			the physics object, should be callled every frame */
		public function updateTransform(pixelsPerMeter:Number):void {
			this.scaleX = pixelsPerMeter;
			this.scaleY = pixelsPerMeter;
			// if physics object is null, just reset to origin...
			if (m_physics != null) {
				var pos:b2Vec2 = m_physics.GetPosition();
				this.x = pos.x * pixelsPerMeter;
				this.y = pos.y * pixelsPerMeter;
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
		
		/*override public function addChild(child:DisplayObject):flash.display.DisplayObject {
			var display:flash.display.DisplayObject = super.addChild(child);
			updateTransform();
			return display;
		}*/
	}
}
