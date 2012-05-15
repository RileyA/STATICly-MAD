package {

	import flash.display.Bitmap;
	import starling.display.Sprite;
	import starling.display.DisplayObject;
	import starling.textures.Texture;
	import starling.display.Image;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Config;
	import Actioners.LevelEntranceActioner;

	/** A basic level gameplay state */
	public class OverworldState extends GameState {

		private var m_level:Level;
		private var m_worldName:String;
		private var completedLevels:Vector.<String>;
		
		[Embed(source = "../media/images/TiledBackground.png")]
		private static const Background:Class;
		
		public function OverworldState(game:Game, worldName:String):void {
			completedLevels=new Vector.<String>();
			super(game);
			m_worldName = worldName;
			tileBG(Background);
			m_level = new Level(this, MiscUtils.loadLevelInfo(m_worldName));
			updateDoors();
			
		}
		
		override public function init():void {
		}
		
		override public function deinit():void {
			//m_level = null;
		}

		/** Called when the state above this is popped and this one is resumed */
		override public function resume():void {
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
			if (Config.debug) {
				isDone ||= Keys.isKeyPressed(Keyboard.ESCAPE);
			}
			return !isDone;
		}

		/**
		* Enter the specified level
		*/
		private function enterLevel(name:String):void {
			if (name == null){ return; }
			else if (name.indexOf("Lab") != -1) {
				m_game.replaceState(m_game.getOverworld(name));
			} else {
				m_game.addState(new LevelState(m_game, name, this));
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
		public function completed(levelName:String):void{
			if (completedLevels.indexOf(levelName)==-1) {
				completedLevels.push(levelName);
				updateDoors();
			}
		}
	}
}
