package {
	import flash.display.Sprite;
	import flash.events.Event;
	import Box2D.Common.Math.*;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
 
	/**
	 * Basic tutorial on Box2DFlash for Dev.Mag www.devmag.org.za
	 * @author Dev.Mag & Ricky Abell
	 */
	public class Main extends Sprite{
		private var world:b2World;
		private var timestep:Number;
		private var velocityIterations:uint;
		private var positionIterations:uint;
		private var pixelsPerMeter:Number = 30;
		private var genBodyTimer:Timer;		
		private var sideWallWidth:int = 20;
		private var bottomWallHeight:int = 25;
		private var blockManager:BlockManager;
 
		public function Main():void{ 
			this.initWorld();
			this.createWalls();
			this.setupDebugDraw();			
 
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init); 
			
			
			this.genBlocks();
		}
 
		private function initWorld():void{
			var gravity:b2Vec2 = new b2Vec2(0.0, 9.8);			
			var doSleep:Boolean = true;
			
			// Construct world
			this.world = new b2World(gravity, doSleep);
			this.world.SetWarmStarting(true);
			this.timestep = 1.0 / 30.0;
			this.velocityIterations = 6;
			this.positionIterations = 4;
		}
 
		private function createWalls():void{
			var wallShape:b2PolygonShape = new b2PolygonShape();
			var wallBd:b2BodyDef = new b2BodyDef();
			var wallB:b2Body;
			
			wallShape.SetAsBox(sideWallWidth / pixelsPerMeter / 2, this.stage.stageHeight / pixelsPerMeter / 2);
 
			//Left wall
			wallBd.position.Set((sideWallWidth / 2) / pixelsPerMeter, this.stage.stageHeight / 2 / pixelsPerMeter);
			wallB = world.CreateBody(wallBd);
			wallB.CreateFixture2(wallShape);
			
			//Right wall
			wallBd.position.Set((this.stage.stageWidth - (sideWallWidth / 2)) / pixelsPerMeter, this.stage.stageHeight / 2 / pixelsPerMeter);
			wallB = world.CreateBody(wallBd);
			wallB.CreateFixture2(wallShape);
			
			//Bottom wall
			wallShape.SetAsBox(this.stage.stageWidth / pixelsPerMeter / 2, bottomWallHeight / pixelsPerMeter / 2);
			wallBd.position.Set(this.stage.stageWidth / 2 / pixelsPerMeter, (this.stage.stageHeight - (bottomWallHeight / 2)) / pixelsPerMeter);
			wallB = world.CreateBody(wallBd);
			wallB.CreateFixture2(wallShape);
 
		}
 
		private function setupDebugDraw():void{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			addChild(debugSprite);
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetDrawScale(30.0);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(debugDraw);
		}
 
		private function init(e:Event = null):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function genBlocks():void{
			blockManager = new BlockManager(world);
			
			var polyShape:b2PolygonShape = new b2PolygonShape();			
			
			polyShape.SetAsBox(1, 1);
			var block:Block = new Block(blockManager,
				new b2Vec2(10,10),
				polyShape,
				Block.charge_red,
				false,
				false,
				false
				);
			var block2:Block = new Block(blockManager,
				new b2Vec2(3,2),
				polyShape,
				Block.charge_red,
				true,
				false,
				false
				);
			
			var block3:Block = new Block(blockManager,
				new b2Vec2(10,2),
				polyShape,
				Block.charge_red,
				true,
				false,
				false
				);
				
			var block4:Block = new Block(blockManager,
				new b2Vec2(2,12),
				polyShape,
				Block.charge_blue,
				true,
				false,
				false
				);
		}
				
		private function update(e:Event = null):void{			
			blockManager.addForces();
			world.Step(timestep, velocityIterations, positionIterations);
			world.ClearForces();
			world.DrawDebugData();
		}
 
	}
	
}