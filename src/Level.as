package {

	import flash.display.Shape;
	import starling.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Player;
	import Chargable.*;

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
		private var m_debugSprite:Sprite;
		private var m_player:Player;
		private var m_gfxPhysObjects:Vector.<GfxPhysObject>;
		private var m_blocks:Vector.<Block>;
		private var m_info:LevelInfo;
		private var m_score:ScoreInfo;
		private var m_chargableManager:ChargableManager;
		private var m_parent_sprite:Sprite;

		// TODO don't hardcode/embed these...
		private static const WIDTH_PIXELS:Number  = 800;
		private static const HEIGHT_PIXELS:Number = 600;

		// Debug controls:
		private static const TOGGLE_DEBUG_DRAW_KEY:Number = Keyboard.D;
		private static const TIMESTEP:Number = 0.033333;
		private static const POSITION_ITERATIONS:uint = 4;
		private static const VELOCITY_ITERATIONS:uint = 6;
		private static const DO_SLEEP:Boolean = true;
		private static const BORDER_THICKNESS:Number = 10;

		public function Level(parent:Sprite, info:LevelInfo):void {

			m_parent_sprite = parent;
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
			m_player = new Player(this, m_parent_sprite, m_info.playerPosition);
			m_chargableManager.addChargable(m_player);
			m_gfxPhysObjects.push(m_player);

			// prep debug stuff
			//prepareDebugVisualization();
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

			if (m_updatePhysics) {
				world.Step(TIMESTEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
				world.ClearForces();
				m_chargableManager.applyChargeForces();
				m_player.update(this);
			}

			for (var i:uint = 0; i < m_gfxPhysObjects.length; ++i)
				m_gfxPhysObjects[i].updateTransform(pixelsPerMeter);

			//if (Keys.isKeyPressed(TOGGLE_DEBUG_DRAW_KEY) && !m_debugDrawKey) {
				//m_debugDrawKey = true;
				//m_debugDraw = !m_debugDraw;
				//m_debugSprite.visible = m_debugDraw;
			//} else if (!Keys.isKeyPressed(TOGGLE_DEBUG_DRAW_KEY) && m_debugDrawKey) {
				//m_debugDrawKey = false;
			//}

			if (m_debugDraw)
				world.DrawDebugData();

			m_score.playerTime += delta;

			return !m_levelDone;
		}

		public function getPlayer():Player{
			return m_player;
		}

		//private function prepareDebugVisualization():void {
			//m_debugSprite = new Sprite();
			//m_parent_sprite.addChild(m_debugSprite);
			//var debugDraw:b2DebugDraw = new b2DebugDraw();
			//debugDraw.SetSprite(m_debugSprite);
			//debugDraw.SetDrawScale(pixelsPerMeter);
			//debugDraw.SetFillAlpha(0.3);
			//debugDraw.SetLineThickness(1.0);
			//debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			//world.SetDebugDraw(debugDraw);
		//}

		private function buildBounds():void {

			// compute pixels per meter and an offset so the playable area
			// is in the center of the screen
			if (m_info.levelSize.x / m_info.levelSize.y 
				>= WIDTH_PIXELS / HEIGHT_PIXELS) {
				pixelsPerMeter = WIDTH_PIXELS / m_info.levelSize.x;
				m_parent_sprite.y = (HEIGHT_PIXELS - m_info.levelSize.y * pixelsPerMeter) / 2.0;
			} else {
				pixelsPerMeter = HEIGHT_PIXELS / m_info.levelSize.y;
				m_parent_sprite.x = (WIDTH_PIXELS - m_info.levelSize.x * pixelsPerMeter) / 2.0;
			}

			var desc:BlockInfo = new BlockInfo();
			desc.scale.x = m_info.levelSize.x;
			desc.scale.y = BORDER_THICKNESS;
			desc.position.x = desc.scale.x / 2;
			desc.position.y = -desc.scale.y / 2;
			desc.movement = "fixed";
			
			var wall:Block = new Block(desc, this);
			m_gfxPhysObjects.push(wall);
			m_parent_sprite.addChild(wall);

			desc.position.y = m_info.levelSize.y + desc.scale.y / 2;

			wall = new Block(desc, this);
			m_gfxPhysObjects.push(wall);
			m_parent_sprite.addChild(wall);

			desc.scale.x = BORDER_THICKNESS;
			desc.scale.y = m_info.levelSize.y;
			desc.position.x = -desc.scale.x / 2;
			desc.position.y = desc.scale.y / 2;

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
