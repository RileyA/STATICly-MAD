package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Config;
	import Actioners.LevelEntranceActioner;

	/** A basic level gameplay state */
	public class OverworldState extends GameState {

		private var m_level:Level;
		private var m_worldName:String;
		private var compleatedLevels:Vector.<String>;
		
		
		public function OverworldState(game:Game, worldName:String):void {
			compleatedLevels=new Vector.<String>();
			super(game);
			m_worldName = worldName;
			m_level = new Level(this, MiscUtils.loadLevelInfo(m_worldName));
			updateDoors();
		}

		override public function init():void {
			LoggerUtils.logLevelStart(m_worldName, null);
		}
		
		override public function deinit():void {
			//m_level = null;
		}

		/** Called when the state above this is popped and this one is resumed */
		override public function resume():void {
			LoggerUtils.logLevelStart(m_worldName, null);
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
				LoggerUtils.logLevelEnd({"didwin":true});
				m_game.replaceState(m_game.getOverworld(name));
			} else {
				LoggerUtils.logLevelEnd({"didwin":false});
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
						(s as LevelEntranceActioner).updateGfx(compleatedLevels);
					}
				}
			}
			
		}
		
		// Called when a level has been beaten
		public function compleated(levelName:String):void{
			if (compleatedLevels.indexOf(levelName)==-1) {
				compleatedLevels.push(levelName);
				updateDoors();
			}
		}
	}
}
