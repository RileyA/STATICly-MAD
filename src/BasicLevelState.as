package 
{
	import GameState;
	import Block;
	import BlockManager;
	import CharacterController;
	import starling.display.Sprite;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	/**
	 * ...
	 * @author Matthew Hall
	 */
	public class BasicLevelState extends GameState {
		
		private var world:b2World;
		private var timestep:Number;
		private var velocityIterations:uint;
		private var positionIterations:uint;
		private var pixelsPerMeter:Number = 50;
		private var blockManager:BlockManager;
		private var characterController:CharacterController;
		
		public function BasicLevelState(game:Game):void {
			super(game);
		}
		
		override public function init():void {
			this.initWorld();
			blockManager = new BlockManager(world);
			
			
			this.createWalls(this.stage.stageWidth, this.stage.stageHeight);
			this.genBlocks();
			
			characterController = new CharacterController(blockManager,new b2Vec2(1,2));
			
			this.setupDebugDraw();			
		}
		
		override public function deinit():void {
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
		
		private function createWall(x1:Number, x2:Number, y1:Number, y2:Number):void{
			Block.MakeRect(blockManager,new b2Vec2(x1,y1),new b2Vec2(x2,y2),Block.charge_none,false,false,true);
		}
		
		// make walls around an area, sized in meters
		// and sets pixelsPerMeter to view the area
		private function createWalls(levelWidth:Number, levelHeight:Number):void{
			var wall_size:Number=1; // wall thickness in meters
			createWall(-wall_size,0,-wall_size,levelHeight+wall_size); // left
			createWall(levelWidth,levelWidth+wall_size,-wall_size,levelHeight+wall_size); // right
			createWall(-wall_size,levelWidth+wall_size,-wall_size,0); // top
			createWall(-wall_size,levelWidth+wall_size,levelHeight,levelHeight+wall_size); // bottom
			
			var pwidth:Number=800;
			var pheight:Number=600;
			pixelsPerMeter = Math.min(pwidth / levelWidth, pheight / levelHeight);
			
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

		// make some blocks to demo
		private function genBlocks():void{
			
			var polyShape:b2PolygonShape = new b2PolygonShape();			
			
			polyShape.SetAsBox(1.5, 1.5);
			var block:Block = new Block(blockManager,
				new b2Vec2(10,10),
				polyShape,
				Block.charge_red,
				false,
				false,
				false
				);

			var block2:Block = new Block(blockManager,
				new b2Vec2(13,10),
				polyShape,
				Block.charge_red,
				false,
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
			
			var i:Number=0;
			for (i=0;i<8;i++){
				Block.MakeRect(blockManager,new b2Vec2(6,i+1),new b2Vec2(9,i+1.3),Block.charge_red,true,true,true);
			}
			
			polyShape.SetAsBox(.5, .5);
			
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
		}

		override public function update(delta:Number):Boolean {
			blockManager.addForces();
			characterController.updateControls(
				isKeyPressed(37),
				isKeyPressed(39),
				isKeyPressed(38));
			world.Step(timestep, velocityIterations, positionIterations);
			world.ClearForces();
			world.DrawDebugData();

			// press escape to exit to menu
			if (isKeyPressed(27)) {
				m_game.addState(new MenuState(m_game));
				return false;
			} else {
				return true;
			}
		}
		
	}
	
}
