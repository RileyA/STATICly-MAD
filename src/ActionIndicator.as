package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Contacts.*;
	import flash.display.*;
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class ActionIndicator extends Sprite {
		
		private var target:b2Body;
		
		private static const SPEED:Number = 1;
		private static const LENGTH:Number = .1;
		
		public function ActionIndicator(player:Player, target:b2Body):void {
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.lineStyle(1.0,0xFFFFFF,1.0,false,LineScaleMode.NONE);
			sprite.graphics.beginFill(0xBBBBBB);
			sprite.graphics.drawRect(0, 0, .2, .2);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		public function update():void {
			
		}
		
	}

}