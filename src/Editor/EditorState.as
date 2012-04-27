package Editor {

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import GameState;

	/** A basic level */
	public class EditorState extends GameState {

		private static const PAUSE_KEY:Number = Keyboard.P;
		private static const RESET_KEY:Number = Keyboard.R;

		private var m_blocks:Vector.<BlockProxy>;
		private var m_player:PlayerProxy;
		private var m_info:LevelInfo;
		private var m_level:Level;
		private var m_pauseKey:Boolean;
		private var m_resetKey:Boolean;
		private var m_paused:Boolean;

		public function EditorState(game:Game):void {
			super(game);
			m_pauseKey = false;
			m_resetKey = false;
			m_paused = true;
		}

		override public function init():void {
			m_level = new Level(this);
			m_blocks = new Vector.<BlockProxy>;
			var block_text:TextField = new TextField();
			block_text.width = 600;
			block_text.height = 500;
			block_text.x = 5;
			block_text.y = 5;
			block_text.text = "Testing Level Editor";
			block_text.selectable = false;
			addChild(block_text);
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

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
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

			if (!m_pauseKey && Keys.isKeyPressed(RESET_KEY)) {
				m_resetKey = true;
				for (i=0;i<m_blocks.length;++i) {
					m_blocks[i].reposition();
				}
				m_player.reposition();
			} else if (!Keys.isKeyPressed(RESET_KEY)) {
				m_resetKey = false;
			}

			m_level.update(delta);

			return !Keys.isKeyPressed(Keyboard.ESCAPE);
		}
	}
}
