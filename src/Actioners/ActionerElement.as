package Actioners
{
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	 * Represents an element that the character can interact with via
	 * the Acition button.
	 */
	public class ActionerElement extends GfxPhysObject{
		public static const EXIT:String = "exit";
		public static const ENTRANCE:String = "entrance";
		public static const INFO:String = "info";

		public static const WIDTH:Number = 1.0;
		public static const HEIGHT:Number = -1.0;

		protected var spriteContainer:DisplayObjectContainer;
		protected var actionString:String;

		/**
		* Accepts a parentBody to attach this fixture to, and
		*/
		public function ActionerElement(rectDef:b2BodyDef, offset:b2Vec2, am:ActionMarker, world:b2World):void {
			this.actionString = actionString;

			var fd:b2FixtureDef = new b2FixtureDef();
			fd.shape = getPolyShape();
			fd.isSensor = true;
			fd.userData = am;
			rectDef.position.Add(offset);
			m_physics = world.CreateBody(rectDef);
			am.fixture = m_physics.CreateFixture(fd);
			
			addChild(getSprite(offset.x, offset.y));
		}

		protected function getPolyShape():b2PolygonShape {
			var ps:b2PolygonShape = new b2PolygonShape();
			ps.SetAsBox(WIDTH, HEIGHT);
			return ps;
		}

		protected function getSprite(x:Number, y:Number):DisplayObjectContainer {
			return this;
		}
		
		/**
		* Returns the action that this element will activate as
		* a String identifier.
		*/
		public function getActionString():String {
			return actionString;
		}

		public function cleanup():void {
			m_physics.GetWorld().DestroyBody(m_physics);
			m_physics = null;
			while (numChildren > 0)
				removeChildAt(0);
		}

		public static function getRelatedType(type:String, rectDef:b2BodyDef, offset:b2Vec2, tokens:Array, world:b2World):ActionerElement {
			
			switch (type) {
			case EXIT:
				return new LevelExitActioner(rectDef, offset, world);
			case ENTRANCE:
				var name:String = tokens[0];
				var count:int = 0;
				if (tokens.length > 1) {
					count = parseInt(tokens[1]);
				}
				return new LevelEntranceActioner(rectDef, offset, world, name, count);
			case INFO:
				return new InfoDisplayActioner(rectDef, offset, world, tokens);
			default:
				return null;
			}
		}
	}
}
