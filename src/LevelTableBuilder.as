package {
	import flash.display.Sprite;
	import starling.core.Starling;
	import LevelAssets;
	import flash.utils.ByteArray
	import flash.net.FileReference
	import OverworldState
	import Actioners.LevelEntranceActioner
	import starling.display.DisplayObject;
	import flash.events.Event
	
	[SWF(backgroundColor='#050505', frameRate='30', width='100', height='100')]

	public class LevelTableBuilder extends Sprite {

		private var m_game:Game;
		private var m_starling:Starling;

		public function LevelTableBuilder():void {
			super();
			m_starling = new Starling(Game, stage);
			m_starling.antiAliasing = 0; // 0 to 16. 0=fast, 2=pretty good looking
			m_starling.showStats=Config.debug;
			m_starling.start();			
			addEventListener(flash.events.Event.ENTER_FRAME, update);
			Keys.init(this);
		}

		public function update(event:flash.events.Event):void {
			if (m_game == null) {
				m_game = Game(m_starling.stage.getChildAt(0));
			} else {
				return;
			}
			
			var file:FileReference = new FileReference();
			var bytes:ByteArray = new ByteArray();
			for(var worldName:String in LevelAssets.qidArray) {
				var id:int = LevelAssets.qidArray[worldName];
				if (OverworldState.isLab(worldName)){
					var overworldState:OverworldState=new OverworldState(m_game, worldName);
					
					
					var blocks:Vector.<Block>=overworldState.m_level.getBlocks();
					var i:int;
					for (i=0;i<blocks.length;i++){
						var num:int=blocks[i].numChildren;
						var k:int;
						for (k=0;k<num;k++){
							var s:DisplayObject=blocks[i].getChildAt(k);
							if (s is LevelEntranceActioner) {
								var lvl:LevelEntranceActioner=(s as LevelEntranceActioner);
								bytes.writeUTFBytes(id.toString()+"\t"+worldName+"\t"+lvl.makeTableString()+"\n");
							}
						}
					}
					
					
					
					

				}	
			}
			file.save(bytes,'levelTable.txt');
		}
	}
}