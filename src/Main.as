package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.*;
	import flash.text.TextField;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	
	[SWF(backgroundColor='#EEEEEE', frameRate='30', width='800', height='600')]
	
	/**
	 * adapted from:
	 * Basic tutorial on Box2DFlash for Dev.Mag www.devmag.org.za
	 * @author Dev.Mag & Ricky Abell
	 * 
	 * key handler adapted from http://lassieadventurestudio.wordpress.com/2008/09/03/as3-key-isdown-behavior/
	 */
	public class Main extends Sprite{
		private var world:b2World;
		private var timestep:Number;
		private var velocityIterations:uint;
		private var positionIterations:uint;
		
		private var debug:TextField;
		
		private var pixelsPerMeter:Number = 50;
		private var blockManager:BlockManager;
		private var characterController:CharacterController;
		
		private var _keys:Array = new Array();
	
		public function Main():void{ 
			this.initWorld();
			blockManager = new BlockManager(world);
			
			this.createWalls(20, 15);
			this.genBlocks();
			
			characterController=new CharacterController(blockManager,new b2Vec2(1,2));
			
			this.setupDebugDraw();			
 
			this.addEventListener(Event.ENTER_FRAME, update);
			
			function handleKeyDown(evt:KeyboardEvent):void{
				if (_keys.indexOf(evt.keyCode) == -1){
					_keys.push(evt.keyCode);
				}
			}
			
			function handleKeyUp(evt:KeyboardEvent):void{
				var i:int = _keys.indexOf(evt.keyCode);
			
				if (i > -1){
					_keys.splice(i, 1);
				}
			}

			
			this.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			this.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			
			stage.focus = this;
			
			debug=new TextField();
            debug.text="Click To Start";
            debug.textColor=0x000000;
            debug.width=600;
            debug.height=100;
            stage.addChild(debug);
			
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			
		}
 		
 		private function clickHandler(event:MouseEvent):void {
		    debug.text="GO!";
            stage.focus = this;
        }
 		
 		public function isKeyPressed(key:int):Boolean{
			return _keys.indexOf(key) > -1;
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
			var size:Number=10; // wall thickness in meters
			createWall(-size,0,-size,levelHeight+size); // left
			createWall(levelWidth,levelWidth+size,-size,levelHeight+size); // right
			createWall(-size,levelWidth+size,-size,0); // top
			createWall(-size,levelWidth+size,levelHeight,levelHeight+size); // bottom
			
			var pwidth:Number=this.stage.stageWidth;
			var pheight:Number=this.stage.stageHeight;
			pixelsPerMeter=Math.min(pwidth/levelWidth,pheight/levelHeight);
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
				
		private function update(e:Event = null):void{			
			blockManager.addForces();
			characterController.updateControls(
				isKeyPressed(37),
				isKeyPressed(39),
				isKeyPressed(38));
			world.Step(timestep, velocityIterations, positionIterations);
			world.ClearForces();
			world.DrawDebugData();
		}
 
	}
	
}




