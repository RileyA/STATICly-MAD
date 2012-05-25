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
		[Embed(source = "../media/images/MaddyNeutralJumping.png")]
		private static const n_jumping:Class;
		[Embed(source = "../media/images/MaddyNeutralRunning.png")]
		private static const n_running:Class;
		[Embed(source = "../media/images/MaddyNeutralRunning.xml", mimeType="application/octet-stream")]
		private static const n_running_xml:Class;
		[Embed(source = "../media/images/MaddyNeutralStanding.png")]
		private static const n_standing:Class;
		[Embed(source = "../media/images/MaddyBlueFalling.png")]
		private static const b_falling:Class;
		[Embed(source = "../media/images/MaddyBlueJumping.png")]
		private static const b_jumping:Class;
		[Embed(source = "../media/images/MaddyBlueRunning.png")]
		private static const b_running:Class;
		[Embed(source = "../media/images/MaddyBlueRunning.xml", mimeType="application/octet-stream")]
		private static const b_running_xml:Class;
		[Embed(source = "../media/images/MaddyBlueStanding.png")]
		private static const b_standing:Class;
		[Embed(source = "../media/images/MaddyRedFalling.png")]
		private static const r_falling:Class;
		[Embed(source = "../media/images/MaddyRedJumping.png")]
		private static const r_jumping:Class;
		[Embed(source = "../media/images/MaddyRedRunning.png")]
		private static const r_running:Class;
		[Embed(source = "../media/images/MaddyRedRunning.xml", mimeType="application/octet-stream")]
		private static const r_running_xml:Class;
		[Embed(source = "../media/images/MaddyRedStanding.png")]
		private static const r_standing:Class;
		
		private static var n_texs:Array;
		private static var r_texs:Array;
		private static var b_texs:Array;
		
		private var n_imgs:Array;
		private var r_imgs:Array;
		private var b_imgs:Array;
		
		private var currentImg:Image;
		private var currentFacing:Boolean;
		private var j:Juggler;
		private static var widthRatio:Number = 0;
		private static var heightRatio:Number = 0;
		private static var scale:Number = 1.2;
		
		public static const FALLING:int = 0;
		public static const JUMPING:int = 1;
		public static const RUNNING:int = 2;
		public static const STANDING:int = 3;
		
		private static const SOME_MAGIC_NUMBER:Number=0.07;
		
		{
			n_texs=[initTex(n_falling),initTex(n_jumping),initTex(n_running),initTex(n_standing)];
			b_texs=[initTex(b_falling),initTex(b_jumping),initTex(b_running),initTex(b_standing)];
			r_texs=[initTex(r_falling),initTex(r_jumping),initTex(r_running),initTex(r_standing)];
		}
		
		public function PlayerSprite(p:Player):void {
			super();
			var i:int;
			n_imgs = new Array(STANDING+1);
			b_imgs = new Array(STANDING+1);
			r_imgs = new Array(STANDING+1);
			for (i=0;i<=STANDING;i++){
				if (i==RUNNING){
					n_imgs[i]=initClip(n_texs[i], XML(new n_running_xml));
					b_imgs[i]=initClip(b_texs[i], XML(new b_running_xml));
					r_imgs[i]=initClip(r_texs[i], XML(new r_running_xml));
				} else {
					n_imgs[i]=initImage(n_texs[i]);
					b_imgs[i]=initImage(b_texs[i]);
					r_imgs[i]=initImage(r_texs[i]);
				}
			}
			initJuggler();
		}
		
		private static function initTex(b:Class):Texture{
			return Texture.fromBitmap(new b);
		}
		
		private static function initImage(b:Texture):Image {
			var result:Image = new Image(b);
			if (widthRatio == 0) {
				widthRatio = result.width;
				heightRatio = result.height;
			}
			result.smoothing = TextureSmoothing.TRILINEAR;
			result.width = result.width / widthRatio * Player.WIDTH * scale;
			result.height = result.height / heightRatio * Player.HEIGHT * scale;
			result.x = -SOME_MAGIC_NUMBER;
			result.y = -result.height;
			return result;
		}
		
		private static function initClip(texture:Texture, sheetXML:XML):MovieClip {
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, sheetXML);
			var frames:Vector.<Texture> = sTextureAtlas.getTextures("running");
			var result:MovieClip = new MovieClip(frames, 2);
			if (widthRatio == 0) {
				widthRatio = result.width;
				heightRatio = result.height;
			}
			result.width = result.width / widthRatio * Player.WIDTH * scale;
			result.height = result.height / heightRatio * Player.HEIGHT * scale;
			result.x = -SOME_MAGIC_NUMBER;
			result.y = -result.height;
			result.play();
			return result;
		}
		
		private function initJuggler():void {
			j = new Juggler();
			j.add(n_imgs[RUNNING]);
			j.add(b_imgs[RUNNING]);
			j.add(r_imgs[RUNNING]);
		}
		
		public function update(p:Player):void {
			j.advanceTime(.1);
			var index:int=chooseMove(p);
			var imgs:Array;
			switch (p.chargePolarity) {
				case ChargableUtils.CHARGE_NONE:
					imgs=n_imgs;
					break;
				case ChargableUtils.CHARGE_BLUE:
					imgs=b_imgs;
					break;
				case ChargableUtils.CHARGE_RED:
					imgs=r_imgs;
			}
			switchImage(imgs[index],p.facingRight(),index==RUNNING);
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
				if (p.getPhysics().GetLinearVelocity().y < -.1)
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
					currentImg.x = currentImg.width - SOME_MAGIC_NUMBER;
				} else {
					currentImg.width = Math.abs(currentImg.width);
					currentImg.x = -SOME_MAGIC_NUMBER;
				}
				addChild(currentImg);
			}
		}
		
	}

}