package {

	import flash.display.Shape;
	import starling.display.Sprite;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Player;
	import Chargable.*;
	import Config
	import starling.core.Starling;
	import Particle.*;
	import starling.textures.Texture;

	public class Level {

		public static const BACKG:int = 0;
		public static const MIDG:int = 1;
		
		public var pixelsPerMeter:Number;
		public var world:b2World;
		public var contactListener:LevelContactListener;
		private var m_levelDone:Boolean;
		private var m_nextLevel:String;
		private var m_updatePhysics:Boolean;
		private var m_debugDraw:Boolean;
		private var m_debugDrawKey:Boolean;
		private var m_debugSprite:flash.display.Sprite;
		private var m_player:Player;
		private var m_gfxPhysObjects:Vector.<GfxPhysObject>;
		private var m_blocks:Vector.<Block>;
		private var m_info:LevelInfo;
		private var m_score:ScoreInfo;
		private var m_chargableManager:ChargableManager;
		private var m_parent_sprite:Sprite;
		private var m_real_parent_sprite:Sprite;
		private var m_backgroundLayer:Sprite;
		private var m_foregroundLayer:Sprite;

		// Debug controls:
		private static const TOGGLE_DEBUG_DRAW_KEY:Number = Keyboard.D;
		private static const TIMESTEP:Number = 0.033333;
		private static const POSITION_ITERATIONS:uint = 4;
		private static const VELOCITY_ITERATIONS:uint = 6;
		private static const DO_SLEEP:Boolean = true;
		private static const BORDER_THICKNESS:Number = 10;

		public var m_particleSys:ParticleSystem;
		public var m_particleE:ParticleEmitter;
		public var m_particles:Vector.<ParticleSystem> 
			= new Vector.<ParticleSystem>();

		public function Level(parent:Sprite, info:LevelInfo):void {

			m_real_parent_sprite = parent;
			m_parent_sprite = new Sprite();
			m_backgroundLayer = new Sprite();
			m_foregroundLayer = new Sprite();

			// parent_sprite has all the usual blocks and stuff, 
			// background and foreground have hints, player is also 
			// in foreground
			m_real_parent_sprite.addChild(m_backgroundLayer);
			m_real_parent_sprite.addChild(m_parent_sprite);
			m_real_parent_sprite.addChild(m_foregroundLayer);

			//m_backgroundLayer.addChild(new Hint(500, 500, 500, 500, 20, 1));

			m_info = info;
			m_debugDraw = false;
			m_updatePhysics = true;
			m_levelDone = false;

			m_chargableManager= new ChargableManager();
			m_gfxPhysObjects = new Vector.<GfxPhysObject>;
			m_blocks = new Vector.<Block>;

			// make world

			world = new b2World(m_info.gravity.toB2Vec2(), DO_SLEEP);
			world.SetWarmStarting(true);

			// compute level scale and add walls
			buildBounds();

			// add in all the blocks
			for (var i:uint = 0; i < m_info.blocks.length; ++i) {
				var loadedBlock:Block = new Block(m_info.blocks[i], this);
				addBlock(loadedBlock);
			}

			// prep the score card
			m_score = new ScoreInfo(m_info.title, Number(m_info.targetTime), 0);

			// make the player
			m_player = new Player(this, m_foregroundLayer, m_info.playerPosition);
			m_chargableManager.addChargable(m_player);
			m_gfxPhysObjects.push(m_player);

			// prep debug stuff
			if (Config.debug) {
				prepareDebugVisualization();
			}
		}

		public function addBlock(b:Block):void {
			m_blocks.push(b);
			m_parent_sprite.addChild(b);
			m_gfxPhysObjects.push(b);
			if (b.isChargableBlock()) {
				m_chargableManager.addChargable(b);
			}
		}

		public function removeBlock(b:Block):void {
			b.deinit();
			for (var i:uint = 0; i < m_blocks.length; ++i) { 
				if (m_blocks[i] == b) {
					m_blocks[i] = m_blocks[m_blocks.length-1];
					m_blocks.pop();
					break;
				}
			}
			for (i = 0; i < m_blocks.length; ++i) { 
				if (m_gfxPhysObjects[i] == b) {
					m_gfxPhysObjects[i] = m_gfxPhysObjects[
						m_gfxPhysObjects.length-1];
					m_gfxPhysObjects.pop();
					break;
				}
			}
			m_parent_sprite.removeChild(b);
			m_chargableManager.removeChargable(b);
		}

		public function addSpark(x:Number, y:Number, 
			scale:Number, meters:Boolean = true, blue:Boolean = true) :void {
			var particleSys:ParticleSystem = new ParticleSystem();
			var emitter:ParticleEmitter = new ParticleEmitter();
			emitter.setTexture(blue ? MiscUtils.sparkTex_bs : MiscUtils.sparkTex_rs);
			//emitter.min_size = Math.sqrt(scale);
			//emitter.max_size = Math.sqrt(scale)*1.25;
			particleSys.addEmitter(emitter);
			particleSys.x = x * (meters ? pixelsPerMeter : 1);
			particleSys.y = y * (meters ? pixelsPerMeter : 1);
			scale = scale * (meters ? pixelsPerMeter : 1);

			var mp:Particle = new Particle(blue ? MiscUtils.sparkTex_b	
				: MiscUtils.sparkTex_r);
			mp.width = scale;
			mp.height = scale;
			mp.x = -scale / 2;
			mp.y = -scale / 2;
			mp.lifespan = 0.3;
			particleSys.addParticle(mp);

			m_particles.push(particleSys);
			m_parent_sprite.addChild(particleSys);
		}

		public function addSparkAction(x:Number, y:Number, 
			scale:Number, meters:Boolean = true) :void {
			var particleSys:ParticleSystem = new ParticleSystem();
			var emitter:ParticleEmitter = new ParticleEmitter();
			emitter.setTexture(MiscUtils.longspark);
			emitter.follow_direction = true;
			emitter.min_size = 12.0;
			emitter.max_size = 25.0;
			emitter.lifespan = 0.07;
			emitter.rotation = Math.PI;
			emitter.maxAngle = 180.0;
			emitter.particlesPerSecond = 15;
			
			particleSys.addEmitter(emitter);
			particleSys.x = x * (meters ? pixelsPerMeter : 1);
			particleSys.y = y * (meters ? pixelsPerMeter : 1);
			scale = scale * (meters ? pixelsPerMeter : 1);

			m_particles.push(particleSys);
			m_parent_sprite.addChild(particleSys);
		}

		public function setUpdatePhysics(updatePhys:Boolean):void {
			m_updatePhysics = updatePhys;
		}

		public function isPhysicsUpdated():Boolean {
			return m_updatePhysics;
		}

		public function getBlocks():Vector.<Block> {
			return m_blocks;
		}
		
		public function getParent():Sprite {
			return m_parent_sprite;
		}

		/**
		* Returns false if the level is marked as finished.
		*/
		public function update(delta:Number):Boolean {

			for (var i:uint = 0; i < m_particles.length; ++i) {
				if (!m_particles[i].update(delta)) {
					m_parent_sprite.removeChild(m_particles[i]);
					if (i != m_particles.length - 1) {
						var tmp:ParticleSystem = m_particles[
							m_particles.length - 1];
						m_particles[i] = tmp;
					}
					m_particles.pop();
					--i;
				}
			}

			if (m_updatePhysics) {
				world.Step(TIMESTEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
				world.ClearForces();
				m_chargableManager.applyChargeForces();
				m_player.update(this);
			}

			for (i = 0; i < m_gfxPhysObjects.length; ++i)
				m_gfxPhysObjects[i].updateTransform(pixelsPerMeter);

			
			if (Config.debug) {
				if (Keys.isKeyPressed(TOGGLE_DEBUG_DRAW_KEY) && !m_debugDrawKey) {
					m_debugDrawKey = true;
					m_debugDraw = !m_debugDraw;
				} else if (!Keys.isKeyPressed(TOGGLE_DEBUG_DRAW_KEY) && m_debugDrawKey) {
					m_debugDrawKey = false;
				}
	
				if (m_debugDraw)
					world.DrawDebugData();
			}

			m_score.playerTime += delta;

			return !m_levelDone;
		}

		public function getPlayer():Player{
			return m_player;
		}

		private function prepareDebugVisualization():void {
			m_debugSprite = new flash.display.Sprite();
			Starling.current.nativeOverlay.addChild(m_debugSprite);
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(m_debugSprite);
			debugDraw.SetDrawScale(pixelsPerMeter);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(debugDraw);
		}

		private function buildBounds():void {

			// compute pixels per meter and an offset so the playable area
			// is in the center of the screen
			const marginY:Number=.93; // make edges show some
			const marginX:Number=.98;
			var HEIGHT_PIXELS:int=Starling.current.viewPort.height;
			var WIDTH_PIXELS:int=Starling.current.viewPort.width;
			
			//Starling.current.stage.stageHeight=HEIGHT_PIXELS;
			//Starling.current.stage.stageWidth=WIDTH_PIXELS;
			
			
			pixelsPerMeter = Math.min(marginX * WIDTH_PIXELS / m_info.levelSize.x,
					marginY * HEIGHT_PIXELS / m_info.levelSize.y);
			
			m_real_parent_sprite.x = (WIDTH_PIXELS - m_info.levelSize.x * pixelsPerMeter) / 2.0;
			m_real_parent_sprite.y = (HEIGHT_PIXELS - m_info.levelSize.y * pixelsPerMeter) / 2.0;

			var desc:BlockInfo = new BlockInfo();
			desc.scale.x = m_info.levelSize.x;
			desc.scale.y = BORDER_THICKNESS;
			desc.position.x = desc.scale.x / 2;
			desc.position.y = -desc.scale.y / 2;
			desc.movement = "fixed";
			desc.strong = false;
			
			var wall:Block = new Block(desc, this);
			m_gfxPhysObjects.push(wall);
			m_parent_sprite.addChild(wall);

			desc.position.y = m_info.levelSize.y + desc.scale.y / 2;

			wall = new Block(desc, this);
			m_gfxPhysObjects.push(wall);
			m_parent_sprite.addChild(wall);

			desc.scale.x = BORDER_THICKNESS;
			desc.scale.y = m_info.levelSize.y+BORDER_THICKNESS*2;
			desc.position.x = -desc.scale.x / 2;
			desc.position.y = desc.scale.y / 2-BORDER_THICKNESS;

			wall = new Block(desc, this);
			m_gfxPhysObjects.push(wall);
			m_parent_sprite.addChild(wall);

			desc.position.x = m_info.levelSize.x + desc.scale.x / 2;

			wall = new Block(desc, this);
			m_gfxPhysObjects.push(wall);
			m_parent_sprite.addChild(wall);
		}

		public function getInfo():LevelInfo {
			return m_info;
		}

		/** Get the current score info for this level. */
		public function getScore():ScoreInfo {
			return m_score;
		}

		/** Mark this level as done.  The update() function will return accordingly. */
		public function markAsDone(nextLevel:String=null):void {
			m_levelDone = true;
			m_nextLevel = nextLevel;
		}

		public function resetLevel():void {
			m_levelDone = false;
			m_nextLevel = null;
		}

		public function getNextLevel():String {
			return m_nextLevel;
		}

		public function getChargableManager():ChargableManager {
			return m_chargableManager;
		}
	}
}
