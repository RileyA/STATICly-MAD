package Surfaces 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import flash.display.Bitmap;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class RedCarpet extends SurfaceElement {
		[Embed(source = "../../media/images/RedCarpet.png")]
		private static const n_tex:Class;
		private static const tex:Texture=Texture.fromBitmap(new n_tex);
		{
			tex.repeat=true;
		}
		
		
		public function RedCarpet(rectDef:b2BodyDef, offset:b2Vec2, w:Number, h:Number, world:b2World):void {
			super(rectDef, offset, w, 1/scalar, LevelContactListener.CARPET_RED_SENSOR_ID, world, tex);
		}
		
		public function actionFunc():void {
			
		}
		
		public function canAction(player:Player):Boolean {
			return true;
		}
	}

}