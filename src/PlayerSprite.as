package  
{
	import flash.display.Bitmap;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.display.Image;

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
		private static var n_running1_img:Image;
		[Embed(source = "../media/images/MaddyNeutralRunning2.png")]
		private static const n_running2:Class;
		private static var n_running2_img:Image;
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
		private static var b_running1_img:Image;
		[Embed(source = "../media/images/MaddyBlueRunning2.png")]
		private static const b_running2:Class;
		private static var b_running2_img:Image;
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
		private static var r_running1_img:Image;
		[Embed(source = "../media/images/MaddyRedRunning2.png")]
		private static const r_running2:Class;
		private static var r_running2_img:Image;
		[Embed(source = "../media/images/MaddyRedStanding.png")]
		private static const r_standing:Class;
		private static var r_standing_img:Image;
		private var currentImg:Image;
		
		public function PlayerSprite():void {
			super();
			if(n_falling_img == null){
				n_falling_img = new Image(Texture.fromBitmap(new n_falling));
				n_floating_img = new Image(Texture.fromBitmap(new n_floating));
				n_jumping_img = new Image(Texture.fromBitmap(new n_jumping));
				n_running1_img = new Image(Texture.fromBitmap(new n_running1));
				n_running2_img = new Image(Texture.fromBitmap(new n_running2));
				n_standing_img = new Image(Texture.fromBitmap(new n_standing));
				b_falling_img = new Image(Texture.fromBitmap(new b_falling));
				b_floating_img = new Image(Texture.fromBitmap(new b_floating));
				b_jumping_img = new Image(Texture.fromBitmap(new b_jumping));
				b_running1_img = new Image(Texture.fromBitmap(new b_running1));
				b_running2_img = new Image(Texture.fromBitmap(new b_running2));
				b_standing_img = new Image(Texture.fromBitmap(new b_standing));
				r_falling_img = new Image(Texture.fromBitmap(new r_falling));
				r_floating_img = new Image(Texture.fromBitmap(new r_floating));
				r_jumping_img = new Image(Texture.fromBitmap(new r_jumping));
				r_running1_img = new Image(Texture.fromBitmap(new r_running1));
				r_running2_img = new Image(Texture.fromBitmap(new r_running2));
				r_standing_img = new Image(Texture.fromBitmap(new r_standing));
			}
			currentImg = n_standing_img;
			currentImg.width = Player.WIDTH;
			currentImg.height = Player.HEIGHT;
			currentImg.y = -currentImg.height;
			addChild(currentImg);
		}
		
		public function update():void {
			
		}
		
	}

}