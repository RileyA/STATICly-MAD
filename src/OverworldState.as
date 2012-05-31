package {

	import flash.display.Bitmap;
	import starling.display.Sprite;
	import starling.display.DisplayObject;
	import starling.textures.Texture;
	import starling.display.Image;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Config;
	import Actioners.LevelEntranceActioner;
	import flash.net.SharedObject;

	/** A basic level gameplay state */
	public class OverworldState extends GameState {

		public var m_level:Level;
		private var m_worldName:String;
		private var completedLevels:Vector.<String>;
		private var m_bestLevelScores:Object;
		private static var so:SharedObject = SharedObject.getLocal("staticlyMad");
		
		[Embed(source = "../media/images/TiledBackground.png")]
		private static const Background:Class;
		
		public function OverworldState(game:Game, worldName:String):void {
			completedLevels=new Vector.<String>();
			m_bestLevelScores = new Object();
			super(game);
			m_worldName = worldName;
			tileBG(Background);
			m_level = new Level(this, MiscUtils.loadLevelInfo(m_worldName));
			updateDoors();
			
		}
		
		override public function init():void {
			resume();
		}
		
		override public function deinit():void {
			suspend();
		}

		/** Called when the state above this is popped and this one is resumed */
		override public function resume():void {
			var menu:Menu = m_game.getMenu();
			menu.setOverworldMenu();
			menu.updateOverworldInfo(m_worldName, m_game.getTotalScore());
			menu.attachTo(this);
		}

		override public function suspend():void {
			m_game.getMenu().removeFrom(this);
		}

		/**
		* Returns false if this LevelState has reached a termination state.
		*/
		override public function update(delta:Number):Boolean {
			var isDone:Boolean = false;
			var levelEnter:Boolean = !m_level.update(delta);
			if (levelEnter) {
				enterLevel(m_level.getNextLevel());
				m_level.resetLevel();
			}
			return !isDone;
		}
		
		
		public static function isLab(name:String):Boolean{
			return name.indexOf("Lab") != -1;
		}
		
		/**
		* Enter the specified level
		*/
		private function enterLevel(name:String):void {
			if (name == null){ return; }
			else if (isLab(name)) {
				if (Config.storage) {
					so.data.last = name;
				}
				m_game.replaceState(m_game.getOverworld(name));
				m_game.getMenu().setOverworldMenu();
			} else {
				m_game.addState(new LevelState(m_game, name, this));
				m_game.getMenu().setLevelMenu();
			}
		}
		
		// update doors to show which can be opened, and which have been beaten
		public function updateDoors():void{
			var blocks:Vector.<Block>=m_level.getBlocks();
			var i:int;
			for (i=0;i<blocks.length;i++){
				var num:int=blocks[i].numChildren;
				var k:int;
				for (k=0;k<num;k++){
					var s:DisplayObject=blocks[i].getChildAt(k);
					if (s is LevelEntranceActioner) {
						(s as LevelEntranceActioner).updateGfx(completedLevels);
					}
				}
			}
		}
		
		// Called when a level has been beaten
		public function completed(levelName:String, score:int):void{
			if (completedLevels.indexOf(levelName)==-1) {
				completedLevels.push(levelName);
				updateDoors();
			}
			var old:int = 0;
			if (levelName in m_bestLevelScores) {
				old = m_bestLevelScores[levelName];
			}
			m_bestLevelScores[levelName] = Math.max(old, score);
			if (Config.storage) {
				so.data.completed[m_worldName + "_" + levelName] = m_bestLevelScores[levelName];
			}
		}

		public function getTotalScore():int {
			var total:int = 0;
			for(var name:String in m_bestLevelScores){
				total += m_bestLevelScores[name];
			}
			return total;
		}
	}
}
