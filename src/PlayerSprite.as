package  
{
	import Box2D.Common.Math.b2Vec2;
	import flash.display.Bitmap;
	import flash.ui.Keyboard;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.textures.TextureAtlas;
	import starling.display.Image;
	import starling.animation.Juggler;
	
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
		[Embed(source = "../media/images/MaddyNeutralRunning.png")]
		private static const n_running:Class;
		[Embed(source = "../media/images/MaddyNeutralRunning.xml", mimeType="application/octet-stream")]
		private static const n_running_xml:Class;
		private static var n_running_clip:MovieClip;
		[Embed(source = "../media/images/MaddyNeutralStanding.png")]
		private static const n_standing:Class;
		private static var n_standing_img:Image;
		[Embed(source = "../media/images/MaddyBlueFalling.png")]
		private static const b_falling:Class;
		private var b_falling_img:Image;
		[Embed(source = "../media/images/MaddyBlueFloating.png")]
		private static const b_floating:Class;
		private var b_floating_img:Image;
		[Embed(source = "../media/images/MaddyBlueJumping.png")]
		private static const b_jumping:Class;
		private var b_jumping_img:Image;
		[Embed(source = "../media/images/MaddyBlueRunning.png")]
		private static const b_running:Class;
		[Embed(source = "../media/images/MaddyBlueRunning.xml", mimeType="application/octet-stream")]
		private static const b_running_xml:Class;
		private var b_running_clip:MovieClip;
		[Embed(source = "../media/images/MaddyBlueStanding.png")]
		private static const b_standing:Class;
		private var b_standing_img:Image;
		[Embed(source = "../media/images/MaddyRedFalling.png")]
		private static const r_falling:Class;
		private var r_falling_img:Image;
		[Embed(source = "../media/images/MaddyRedFloating.png")]
		private static const r_floating:Class;
		private var r_floating_img:Image;
		[Embed(source = "../media/images/MaddyRedJumping.png")]
		private static const r_jumping:Class;
		private var r_jumping_img:Image;
		[Embed(source = "../media/images/MaddyRedRunning.png")]
		private static const r_running:Class;
		[Embed(source = "../media/images/MaddyRedRunning.xml", mimeType="application/octet-stream")]
		private static const r_running_xml:Class;
		private var r_running_clip:MovieClip;
		[Embed(source = "../media/images/MaddyRedStanding.png")]
		private static const r_standing:Class;
		private var r_standing_img:Image;
		
		private var currentImg:Image;
		private var currentFacing:Boolean;
		private var j:Juggler;
		private static var widthRatio:Number = 0;
		private static var heightRatio:Number = 0;
		private static var scale:Number = 1.2;
		
		public static const FALLING:int = 1;
		public static const FLOATING:int = 2;
		public static const JUMPING:int = 3;
		public static const RUNNING:int = 4;
		public static const STANDING:int = 5;
		
		public function PlayerSprite(p:Player):void {
			super();
			if (n_falling_img == null) {
				n_falling_img = initImage(new n_falling);
				n_floating_img = initImage(new n_floating);
				n_jumping_img = initImage(new n_jumping);
				n_standing_img = initImage(new n_standing);
				b_falling_img = initImage(new b_falling);
				b_floating_img = initImage(new b_floating);
				b_jumping_img = initImage(new b_jumping);
				b_standing_img = initImage(new b_standing);
				r_falling_img = initImage(new r_falling);
				r_floating_img = initImage(new r_floating);
				r_jumping_img = initImage(new r_jumping);
				r_standing_img = initImage(new r_standing);
				
				n_running_clip = initClip(new n_running, XML(new n_running_xml));
				b_running_clip = initClip(new b_running, XML(new b_running_xml));
				r_running_clip = initClip(new r_running, XML(new r_running_xml));
			}
			initJuggler();
		}
		
		private function initImage(b:Bitmap):Image {
			var result:Image = Image.fromBitmap(b);
			if (widthRatio == 0) {
				widthRatio = result.width;
				heightRatio = result.height;
			}
			result.smoothing = TextureSmoothing.TRILINEAR;
			result.width = result.width / widthRatio * Player.WIDTH * scale;
			result.height = result.height / heightRatio * Player.HEIGHT * scale;
			result.x = -.07;
			result.y = -result.height;
			return result;
		}
		
		private function initClip(b:Bitmap, sheetXML:XML):MovieClip {
			var texture:Texture = Texture.fromBitmap(b);
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, sheetXML);
			var frames:Vector.<Texture> = sTextureAtlas.getTextures("running");
			var result:MovieClip = new MovieClip(frames, 2);
			if (widthRatio == 0) {
				widthRatio = result.width;
				heightRatio = result.height;
			}
			result.width = result.width / widthRatio * Player.WIDTH * scale;
			result.height = result.height / heightRatio * Player.HEIGHT * scale;
			result.x = -.07;
			result.y = -result.height;
			result.play();
			return result;
		}
		
		private function initJuggler():void {
			j = new Juggler();
			j.add(n_running_clip);
			j.add(b_running_clip);
			j.add(r_running_clip);
		}
		
		public function update(p:Player):void {
			j.advanceTime(.1);
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
							switchImage(n_running_clip, p.facingRight(), true);
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
							switchImage(b_running_clip, p.facingRight(), true);
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
							switchImage(r_running_clip, p.facingRight(), true);
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
			var left:Boolean=Keys.any(Keyboard.LEFT,Keyboard.A);
			var right:Boolean=Keys.any(Keyboard.RIGHT,Keyboard.D);
			if (p.jumpable()) {
				if (left || right) {
					return RUNNING;
				} else {
					return STANDING;
				}
			} else {
				if (p.getPhysics().GetLinearVelocity().y < 0)
					return JUMPING;
				else
					return FALLING;
			}
			
		}
		
		private function switchImage(newImg:Image, right:Boolean, isMovie:Boolean = false):void {
			if (newImg != currentImg || right != currentFacing) {
				if (currentImg != null){
					removeChild(currentImg);
				}
				currentImg = newImg;
				currentFacing = right;
				
				if (!right) {
					currentImg.width *= -1;
					currentImg.x = currentImg.width - .07;
				} else {
					currentImg.width = Math.abs(currentImg.width);
					currentImg.x = -.07;
				}
				addChild(currentImg);
			}
		}
		
	}

}