package  
{
	import Box2D.Common.Math.b2Vec2;
	import flash.display.Bitmap;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.display.Image;
	
	import Chargable.ChargableUtils;

	public class PlayerSprite extends Sprite {
		
		[Embed(source = "../media/images/MaddyNeutralFalling.png")]
		private static const n_falling:Class;
		private static var n_falling_img:Image;
		[Embed(source = "../media/images/MaddyNeutralFloating.png")]
		private static const n_floating:Class;
		private static var n_floating_img:Image;
		[Embed(source = "../media/images/MaddyNeutralJumping.png")]
		private static const n_jumping:Class;
		private static var n_jumping_img:Image;
		[Embed(source = "../media/images/MaddyNeutralRunning1.png")]
		private static const n_running1:Class;
		private static var n_running_img:Image;
		//[Embed(source = "../media/images/MaddyNeutralRunning2.png")]
		//private static const n_running2:Class;
		//private static var n_running2_img:Image;
		[Embed(source = "../media/images/MaddyNeutralStanding.png")]
		private static const n_standing:Class;
		private static var n_standing_img:Image;
		[Embed(source = "../media/images/MaddyBlueFalling.png")]
		private static const b_falling:Class;
		private static var b_falling_img:Image;
		[Embed(source = "../media/images/MaddyBlueFloating.png")]
		private static const b_floating:Class;
		private static var b_floating_img:Image;
		[Embed(source = "../media/images/MaddyBlueJumping.png")]
		private static const b_jumping:Class;
		private static var b_jumping_img:Image;
		[Embed(source = "../media/images/MaddyBlueRunning1.png")]
		private static const b_running1:Class;
		private static var b_running_img:Image;
		//[Embed(source = "../media/images/MaddyBlueRunning2.png")]
		//private static const b_running2:Class;
		//private static var b_running2_img:Image;
		[Embed(source = "../media/images/MaddyBlueStanding.png")]
		private static const b_standing:Class;
		private static var b_standing_img:Image;
		[Embed(source = "../media/images/MaddyRedFalling.png")]
		private static const r_falling:Class;
		private static var r_falling_img:Image;
		[Embed(source = "../media/images/MaddyRedFloating.png")]
		private static const r_floating:Class;
		private static var r_floating_img:Image;
		[Embed(source = "../media/images/MaddyRedJumping.png")]
		private static const r_jumping:Class;
		private static var r_jumping_img:Image;
		[Embed(source = "../media/images/MaddyRedRunning1.png")]
		private static const r_running1:Class;
		private static var r_running_img:Image;
		//[Embed(source = "../media/images/MaddyRedRunning2.png")]
		//private static const r_running2:Class;
		//private static var r_running2_img:Image;
		[Embed(source = "../media/images/MaddyRedStanding.png")]
		private static const r_standing:Class;
		private static var r_standing_img:Image;
		
		private var currentImg:Image;
		private var currentFacing:Boolean;
		
		public static const FALLING:int = 1;
		public static const FLOATING:int = 2;
		public static const JUMPING:int = 3;
		public static const RUNNING:int = 4;
		public static const STANDING:int = 5;
		
		public function PlayerSprite(p:Player):void {
			super();
			if(n_falling_img == null){
				n_falling_img = new Image(Texture.fromBitmap(new n_falling));
				n_floating_img = new Image(Texture.fromBitmap(new n_floating));
				n_jumping_img = new Image(Texture.fromBitmap(new n_jumping));
				n_running_img = new Image(Texture.fromBitmap(new n_running1));
				//n_running2_img = new Image(Texture.fromBitmap(new n_running2));
				n_standing_img = new Image(Texture.fromBitmap(new n_standing));
				b_falling_img = new Image(Texture.fromBitmap(new b_falling));
				b_floating_img = new Image(Texture.fromBitmap(new b_floating));
				b_jumping_img = new Image(Texture.fromBitmap(new b_jumping));
				b_running_img = new Image(Texture.fromBitmap(new b_running1));
				//b_running2_img = new Image(Texture.fromBitmap(new b_running2));
				b_standing_img = new Image(Texture.fromBitmap(new b_standing));
				r_falling_img = new Image(Texture.fromBitmap(new r_falling));
				r_floating_img = new Image(Texture.fromBitmap(new r_floating));
				r_jumping_img = new Image(Texture.fromBitmap(new r_jumping));
				r_running_img = new Image(Texture.fromBitmap(new r_running1));
				//r_running2_img = new Image(Texture.fromBitmap(new r_running2));
				r_standing_img = new Image(Texture.fromBitmap(new r_standing));
			}
			switchImage(n_standing_img, p.facingRight());
		}
		
		public function update(p:Player):void {
			var v:b2Vec2 = p.getPhysics().GetLinearVelocity();
			switch (p.chargePolarity) {
				case ChargableUtils.CHARGE_NONE:
					switch(chooseMove(p)) {
						case FALLING:
							switchImage(n_falling_img, p.facingRight());
							break;
						case FLOATING:
							switchImage(n_floating_img, p.facingRight());
							break;
						case JUMPING:
							switchImage(n_jumping_img, p.facingRight());
							break;
						case RUNNING:
							switchImage(n_running_img, p.facingRight());
							break;
						case STANDING:
							switchImage(n_standing_img, p.facingRight());
							break;
					}
					break;
				case ChargableUtils.CHARGE_BLUE:
					switch(chooseMove(p)) {
						case FALLING:
							switchImage(b_falling_img, p.facingRight());
							break;
						case FLOATING:
							switchImage(b_floating_img, p.facingRight());
							break;
						case JUMPING:
							switchImage(b_jumping_img, p.facingRight());
							break;
						case RUNNING:
							switchImage(b_running_img, p.facingRight());
							break;
						case STANDING:
							switchImage(b_standing_img, p.facingRight());
							break;
					}
					break;
				case ChargableUtils.CHARGE_RED:
					switch(chooseMove(p)) {
						case FALLING:
							switchImage(r_falling_img, p.facingRight());
							break;
						case FLOATING:
							switchImage(r_floating_img, p.facingRight());
							break;
						case JUMPING:
							switchImage(r_jumping_img, p.facingRight());
							break;
						case RUNNING:
							switchImage(r_running_img, p.facingRight());
							break;
						case STANDING:
							switchImage(r_standing_img, p.facingRight());
							break;
					}
					break;
			}
				
		}
		
		private function chooseMove(p:Player):int {
			var v:b2Vec2 = p.getPhysics().GetLinearVelocity();
			if (p.jumpable()) {
				if (v.Length() < .5) {
					return STANDING;
				} else {
					return RUNNING;
				}
			}else {
				if (v.y < 0)
					return FALLING;
				else
					return JUMPING;
			}
			
		}
		
		private function switchImage(newImg:Image, right:Boolean):void {
			if(newImg != currentImg || right != currentFacing) {
				if (currentImg != null){
					removeChild(currentImg);
					if (!currentFacing){
						currentImg.scaleX *= -1;
						currentImg.x = 0;
					}
				}
				currentImg = newImg;
				currentFacing = right;
				currentImg.width = Player.WIDTH;
				if (!right) {
					//trace("left");
					currentImg.scaleX *= -1;
					currentImg.x += Player.WIDTH;
				}
				currentImg.height = Player.HEIGHT;
				currentImg.y = -currentImg.height;
				addChild(currentImg);
			}
		}
		
	}

}