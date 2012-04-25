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
		private var actionString:String;

		/**
		* Accepts a parentBody to attach this fixture to, and
		*/
		public function ActionerElement(position:b2Vec2, scale:b2Vec2, am:ActionMarker, parentBody:b2Body, actionString:String):void {
			super(parentBody);
			this.actionString = actionString;

			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(scale.x / 2, scale.y / 2);
			fd.shape = ps;
			fd.isSensor = true;
			rectDef.position = position;
			rectDef.angle = 0.0;
			
			fd.userData = am;
			
			parentBody.CreateFixture(fd);
		}
		
		/**
		* Returns the action that this element will activate as
		* a String identifier.
		*/
		public function getActionString():String {
			return actionString;
		}
	}
}
