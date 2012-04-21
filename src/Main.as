package {
	import flash.display.Sprite;
	import flash.events.Event;
	import Box2D.Common.Math.*;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
 	
 	[SWF(backgroundColor='#EEEEEE', frameRate='30', width='800', height='600')]
 	
	/**
	 * adapted from:
	 * Basic tutorial on Box2DFlash for Dev.Mag www.devmag.org.za
	 * @author Dev.Mag & Ricky Abell
	 */
	public class Main extends Sprite{
		private var world:b2World;
		private var timestep:Number;
		private var velocityIterations:uint;
		private var positionIterations:uint;
		
		private var levelWidth:Number=20; // in meters
		private var levelHeight:Number=15; // in meters
		
		
		private var pixelsPerMeter:Number = 50;
		private var genBodyTimer:Timer;		
		private var sideWallWidth:int = 100; // in px
		private var bottomWallHeight:int = 100; // in px
		private var blockManager:BlockManager;
 
		public function Main():void{ 
			this.initWorld();
			blockManager = new BlockManager(world);
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
 		
 		private function createWall(width:Number, height:Number, x:Number, y:Number):void{
 			var polyShape:b2PolygonShape = new b2PolygonShape();	
 			polyShape.SetAsBox(width, height);
 			new Block(blockManager,
				new b2Vec2(x,y),
				polyShape,
				Block.charge_none,
				false,
				false,
				true
				);
 		}
 		
		private function createWalls():void{
			var pwidth:Number=this.stage.stageWidth;
			var pheight:Number=this.stage.stageHeight;
			pixelsPerMeter=Math.min(pwidth/levelWidth,pheight/levelHeight);
			
			var ww:Number=sideWallWidth / pixelsPerMeter / 2;
			var wh:Number=bottomWallHeight / pixelsPerMeter / 2;
			
			var w:Number=levelWidth/2;
			var h:Number=levelHeight/2;

			createWall(w+ww*2, wh, w, -wh);
			createWall(w+ww*2, wh, w,2*h+wh);
			
			createWall(ww, h+wh*2, -ww, h);
			createWall(ww, h+wh*2, 2*w+ww,h);
		}
 
		private function setupDebugDraw():void{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			addChild(debugSprite);
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetDrawScale(pixelsPerMeter);
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
			
			
			var polyShape:b2PolygonShape = new b2PolygonShape();			
			
			polyShape.SetAsBox(.5, .5);
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
			
			
			polyShape = new b2PolygonShape();			
			
			polyShape.SetAsBox(3, .3);
			
			new Block(blockManager,
				new b2Vec2(10,1),
				polyShape,
				Block.charge_red,
				true,
				false,
				false
				);
			
			polyShape.SetAsBox(.5, .5);
			var i:Number=0;
			for (i=0;i<25;i++){
				new Block(blockManager,
				new b2Vec2(2+(i%5),4+i/5),
				polyShape,
				Block.charge_red,
				true,
				false,
				false
				);
			}
			
			//Block.MakeRect(blockManager,new b2Vec2(0,0),new b2Vec2(20,15),Block.charge_none,true,false,true);
			
			
		}
				
		private function update(e:Event = null):void{			
			blockManager.addForces();
			world.Step(timestep, velocityIterations, positionIterations);
			world.ClearForces();
			world.DrawDebugData();
		}
 
	}
	
}