package Actioners
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	 * Represents an element that the character can interact with via
	 * the Acition button.
	 */
	public class ActionerElement extends GfxPhysObject{
		public static const EXIT:String = "exit";
		public static const SWITCH:String = "switch";
		public static const FIXED:String = "fixed";

		private var actionString:String;

		/**
		* Accepts a parentBody to attach this fixture to, and
		*/
		public function ActionerElement(rectDef:b2BodyDef, offset:b2Vec2, w:Number, h:Number, am:ActionMarker, world:b2World):void {
			this.actionString = actionString;

			var fd:b2FixtureDef = new b2FixtureDef();
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(w / 2, h / 2); // load a sprite?
			fd.shape = ps;
			fd.isSensor = true;
			rectDef.position.Add(offset);
			rectDef.angle = 0.0;
			
			fd.userData = am;
			
			m_physics = world.CreateBody(rectDef);
			m_physics.CreateFixture(fd);
		}
		
		/**
		* Returns the action that this element will activate as
		* a String identifier.
		*/
		public function getActionString():String {
			return actionString;
		}

		public static function getRelatedType(type:String,rectDef:b2BodyDef, offset:b2Vec2, w:Number, h:Number, am:ActionMarker, world:b2World):ActionerElement {
			
			if (type == EXIT)
				return new LevelExitActioner(rectDef, offset, w, h, am, world);
			else
				return null;
		}
	}
}
