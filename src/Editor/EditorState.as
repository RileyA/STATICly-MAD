package Editor {

	import flash.display.Shape;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import flash.events.Event;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import GameState;

	/** A basic level */
	public class EditorState extends GameState {

		private static const PAUSE_KEY:Number = Keyboard.P;
		private static const RESET_KEY:Number = Keyboard.R;
		private static const SAVE_KEY:Number = Keyboard.S;

		private var m_blocks:Vector.<BlockProxy>;
		private var m_player:PlayerProxy;
		private var m_info:LevelInfo;
		private var m_level:Level;

		private var m_pauseKey:Boolean;
		private var m_resetKey:Boolean;
		private var m_paused:Boolean;

		private var m_levelLoaded:Boolean;
		private var m_loadRef:FileReference;

		public function EditorState(game:Game):void {
			super(game);
			m_pauseKey = false;
			m_resetKey = false;
			m_paused = true;
		}

		override public function init():void {
			/** create editor UI stuffs */
			m_levelLoaded = false;

			m_loadRef = new FileReference();
			m_loadRef.addEventListener(Event.SELECT, selectionComplete);
			var fileFilter:FileFilter 
				= new FileFilter("Levels: (*.json)", "*.json");
			m_loadRef.browse([fileFilter]);
			
		}

		public function loadLevel(info:LevelInfo):void {
			var block_text:TextField = new TextField();
			block_text.width = 600;
			block_text.height = 500;
			block_text.x = 5;
			block_text.y = 5;
			block_text.text = "Editing: " + info.title;
			block_text.selectable = false;
			addChild(block_text);

			m_level = new Level(this, info);
			m_blocks = new Vector.<BlockProxy>;
			m_level.setUpdatePhysics(!m_paused);
			m_level.update(0);
			var blocks:Vector.<Block> = m_level.getBlocks();
			for (var i:uint=0;i<blocks.length;++i) {
				var proxy:BlockProxy = new BlockProxy(blocks[i]);
				m_blocks.push(proxy);
				addChild(proxy);
			}
			m_player = new PlayerProxy(m_level.getPlayer());
			addChild(m_player);
		}

		private function selectionComplete(e:Event):void {
			m_loadRef.removeEventListener(Event.SELECT, selectionComplete);
			m_loadRef.addEventListener(Event.COMPLETE, loadComplete);
			m_loadRef.load();
		}

		private function loadComplete(e:Event):void {
			m_loadRef.removeEventListener(Event.COMPLETE, loadComplete);
			var info :LevelInfo = new LevelInfo();
			MiscUtils.loadJSON(m_loadRef.data as ByteArray, info);
			loadLevel(info);
			m_levelLoaded = true;
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			if (m_levelLoaded) {
				if (!m_pauseKey && Keys.isKeyPressed(PAUSE_KEY)) {
					m_paused = !m_paused;
					m_level.setUpdatePhysics(!m_paused);

					if (!m_paused) {
						var blocks:Vector.<Block> = m_level.getBlocks();
						for (var i:uint=0;i<blocks.length;++i) {
							blocks[i].getPhysics().SetAwake(true);
						}
					}

					m_pauseKey = true;
				} else if(!Keys.isKeyPressed(PAUSE_KEY)) {
					m_pauseKey = false;
				}

				if (!m_resetKey && Keys.isKeyPressed(RESET_KEY)) {
					m_resetKey = true;
					for (i=0;i<m_blocks.length;++i) {
						m_blocks[i].reposition();
					}
					m_player.reposition();
				} else if (!Keys.isKeyPressed(RESET_KEY)) {
					m_resetKey = false;
				}

				m_level.update(delta);
			}

			return !Keys.isKeyPressed(Keyboard.ESCAPE);
		}
	}
}
