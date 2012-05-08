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
	import flash.events.MouseEvent;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import GameState;

	// abandone all hope ye who enter here...
	public class EditorState extends GameState {

		private static const PAUSE_KEY:Number = Keyboard.P;
		private static const RESET_KEY:Number = Keyboard.R;
		private static const BLOCK_KEY:Number = Keyboard.SHIFT;
		private static const WIDGET_KEY:Number = Keyboard.W;
		private static const DELETE_KEY:Number = Keyboard.BACKSPACE;
		private static const COPY_KEY:Number = Keyboard.C;
		private static const PASTE_KEY:Number = Keyboard.V;

		private var m_blocks:Vector.<BlockProxy>;
		private var m_player:PlayerProxy;
		private var m_info:LevelInfo;
		private var m_level:Level;

		private var m_pauseKey:Boolean;
		private var m_resetKey:Boolean;
		private var m_widgetKey:Boolean;
		private var m_pasteKey:Boolean;
		private var m_widgetsHidden:Boolean;
		private var m_paused:Boolean;

		private var m_levelInfo:LevelInfo;
		private var m_levelLoaded:Boolean;
		private var m_loadRef:FileReference;
		private var m_menu:EditorMenu;

		private var m_focused:EditorProxy;
		private var m_copied:BlockInfo = null;

		private var m_levelSprite:Sprite;

		public function EditorState(game:Game):void {
			super(game);
			m_pauseKey = true;
			m_resetKey = true;
			m_widgetKey = true;
			m_widgetsHidden = false;
			m_paused = true;
		}

		override public function init():void {
			/** create editor UI stuffs */
			m_levelLoaded = false;
			m_levelSprite = new Sprite();

			// add something clickable
			var s:Shape = new Shape();
			s.alpha = 0.0;
			s.graphics.beginFill(0x000000);
			s.graphics.drawRect(-800,-600,2400,1800);
			s.graphics.endFill();
			m_levelSprite.addChild(s);
			addChild(m_levelSprite);

			m_menu = new EditorMenu("New Level");
			addChild(m_menu);
			addEventListener(MouseEvent.CLICK, addBlock);
			addEventListener(MouseEvent.MOUSE_DOWN, handleFocus);
			m_menu.saveButton.addEventListener(MouseEvent.CLICK, save);
			m_menu.loadButton.addEventListener(MouseEvent.CLICK, load);
			m_menu.newButton.addEventListener(MouseEvent.CLICK, newLevel);
			m_menu.resetButton.addEventListener(MouseEvent.CLICK, resetClicked);
			m_menu.pauseButton.addEventListener(MouseEvent.CLICK, pauseClicked);
			m_menu.x = 50;
			m_menu.y = 50;
			newLevel(new MouseEvent(MouseEvent.CLICK));
		}

		private function unloadLevel():void {
			m_focused = null;
			m_levelSprite.x = 0;
			m_levelSprite.y = 0;
			m_level = null;
			while (m_levelSprite.numChildren > 0)
				m_levelSprite.removeChildAt(0);
			m_levelLoaded = false;
			var s:Shape = new Shape();
			s.alpha = 0.0;
			s.graphics.beginFill(0x000000);
			s.graphics.drawRect(-800,-600,2400,1800);
			s.graphics.endFill();
			m_levelSprite.addChild(s);
		}

		public function loadLevel(info:LevelInfo):void {
			m_menu.levelName.text = info.title;
			m_level = new Level(m_levelSprite, info);
			m_blocks = new Vector.<BlockProxy>;
			m_level.setUpdatePhysics(!m_paused);
			m_level.update(0);

			var blocks:Vector.<Block> = m_level.getBlocks();
			for (var i:uint=0;i<blocks.length;++i) {
				var proxy:BlockProxy = new BlockProxy(blocks[i]);
				m_blocks.push(proxy);
				m_levelSprite.addChild(proxy);
			}
			m_player = new PlayerProxy(m_level.getPlayer());
			m_levelSprite.addChild(m_player);
		}

		private function selectionComplete(e:Event):void {
			unloadLevel();
			m_loadRef.removeEventListener(Event.SELECT, selectionComplete);
			m_loadRef.addEventListener(Event.COMPLETE, loadComplete);
			m_loadRef.load();
		}

		private function loadComplete(e:Event):void {
			m_loadRef.removeEventListener(Event.COMPLETE, loadComplete);
			m_levelInfo = new LevelInfo();
			MiscUtils.loadJSON(m_loadRef.data as ByteArray, m_levelInfo);
			loadLevel(m_levelInfo);
			m_levelLoaded = true;
			if (!m_paused) togglePause();
		}

		override public function deinit():void {
		}

		override public function update(delta:Number):Boolean {
			if (m_levelLoaded) {
				if (m_focused) m_focused.updateForm();
				if (!m_pauseKey && Keys.isKeyPressed(PAUSE_KEY)) {
					togglePause();
					m_pauseKey = true;
				} else if(!Keys.isKeyPressed(PAUSE_KEY)) {
					m_pauseKey = false;
				}

				if (!m_resetKey && Keys.isKeyPressed(RESET_KEY)) {
					m_resetKey = true;
					doReset();
				} else if (!Keys.isKeyPressed(RESET_KEY)) {
					m_resetKey = false;
				}

				if (!m_widgetKey && Keys.isKeyPressed(WIDGET_KEY)) {
					toggleWidgets();
					m_widgetKey = true;
				} else if (!Keys.isKeyPressed(WIDGET_KEY)) {
					m_widgetKey = false;
				}

				if (Keys.isKeyPressed(DELETE_KEY)) {
					if (m_focused && m_focused is BlockProxy) {
						var bp:BlockProxy = m_focused as BlockProxy;
						m_level.removeBlock(bp.getBlock());
						for (var i:uint=0; i < m_blocks.length; ++i) {
							if (m_blocks[i] == m_focused) {
								m_blocks[i] = m_blocks[m_blocks.length - 1];
								m_blocks.pop();
								break;
							}
						}
						m_levelSprite.removeChild(bp);
						m_focused = null;
						refocus(null);
						bp = null;
					}
				}

				if (Keys.isKeyPressed(COPY_KEY)){
					if(m_focused && m_focused is BlockProxy) {
						m_copied = (m_focused as BlockProxy).getBlock()
							.getInfo().getCopy();
					}
				}

				if (Keys.isKeyPressed(PASTE_KEY) && !m_pasteKey) {
					m_pasteKey = true;
					if (m_copied) {
						var info:BlockInfo = m_copied.getCopy();
						info.position.x = m_levelSprite.mouseX 
							/ m_level.pixelsPerMeter;
						info.position.y = m_levelSprite.mouseY 
							/ m_level.pixelsPerMeter;
						var newBlock:Block = new Block(info, m_level);
						m_level.addBlock(newBlock);
						newBlock.updateTransform(m_level.pixelsPerMeter);
						var proxy:BlockProxy = new BlockProxy(newBlock);
						m_blocks.push(proxy);
						m_levelSprite.addChild(proxy);
						m_levelSprite.swapChildren(newBlock, m_player.getPlayer());
						m_levelSprite.swapChildren(proxy, m_player);
						if (!m_widgetsHidden) {
							refocus(proxy);
						} else {
							refocus(null);
						}
						proxy.visible = !m_widgetsHidden;
					}
				} else if (!Keys.isKeyPressed(PASTE_KEY) && m_pasteKey) {
					m_pasteKey = false;
				}

				if (!m_level.update(delta)) {
					if (!m_paused) togglePause();
					doReset();
					m_level.resetLevel();
				}
			}

			return !Keys.isKeyPressed(Keyboard.ESCAPE);
		}

		public function addBlock(e:MouseEvent):void { 
			if (!m_levelLoaded) return;
			if (e.target == m_levelSprite 
				&& Keys.isKeyPressed(BLOCK_KEY)) {

				// make a new block, default 1x1 meter, fixed
				var info:BlockInfo = new BlockInfo();
				info.scale.x = 1;
				info.scale.y = 1;
				info.position.x = m_levelSprite.mouseX / m_level.pixelsPerMeter;
				info.position.y = m_levelSprite.mouseY / m_level.pixelsPerMeter;
				info.movement = "fixed";
				info.insulated = false;
				info.strong = false;

				var newBlock:Block = new Block(info, m_level);
				m_level.addBlock(newBlock);
				newBlock.updateTransform(m_level.pixelsPerMeter);
				var proxy:BlockProxy = new BlockProxy(newBlock);
				m_blocks.push(proxy);
				m_levelSprite.addChild(proxy);
				m_levelSprite.swapChildren(newBlock, m_player.getPlayer());
				m_levelSprite.swapChildren(proxy, m_player);
				if (!m_widgetsHidden) {
					refocus(proxy);
				} else {
					refocus(null);
				}
				proxy.visible = !m_widgetsHidden;
			} else {
				handleFocus(e);
			}
		}

		public function handleFocus(e:MouseEvent):void { 
			if (!m_levelLoaded) return;
			if (e.target.parent is EditorProxy
				|| e.target is EditorProxy) {
				var tmp:EditorProxy = e.target.parent is EditorProxy ? 
					e.target.parent as EditorProxy : e.target as EditorProxy;
				refocus(tmp);
			} else if(e.target == m_levelSprite) {
				refocus(null);
			}
		}

		public function save(e:MouseEvent):void {
			e.stopPropagation();
			if (m_levelLoaded) {
				m_levelInfo.blocks = new Vector.<BlockInfo>;
				m_levelInfo.title = m_menu.levelName.text;
				var blocks:Vector.<Block> = m_level.getBlocks();
				for (var i:uint = 0; i < blocks.length; ++i)
					m_levelInfo.blocks.push(blocks[i].getInfo());
				m_levelInfo.playerPosition = m_player.getPos();
				var saver:FileReference = new FileReference();
				saver.save(MiscUtils.outputJSON(m_levelInfo),
					m_levelInfo.title + ".json");
			}
		}

		public function load(e:MouseEvent):void {
			e.stopPropagation();
			m_loadRef = new FileReference();
			m_loadRef.addEventListener(Event.SELECT, selectionComplete);
			var fileFilter:FileFilter 
				= new FileFilter("Levels: (*.json)", "*.json");
			m_loadRef.browse([fileFilter]);
		}

		public function pauseClicked(e:MouseEvent):void {
			togglePause();
		}

		public function resetClicked(e:MouseEvent):void {
			doReset();
		}

		public function newLevel(e:MouseEvent):void {
			e.stopPropagation();
			unloadLevel();
			var info:LevelInfo = new LevelInfo();
			m_levelInfo = info;
			info.title = m_menu.levelName.text;
			info.levelSize.x = parseFloat(m_menu.levelW.text);
			info.levelSize.y = parseFloat(m_menu.levelH.text);
			info.playerPosition.x = parseFloat(m_menu.levelW.text)/2;
			info.playerPosition.y = parseFloat(m_menu.levelH.text)/2;
			m_level = new Level(m_levelSprite, info);
			m_level.setUpdatePhysics(!m_paused);
			m_level.update(0);
			m_player = new PlayerProxy(m_level.getPlayer());
			m_levelSprite.addChild(m_player);
			m_blocks = new Vector.<BlockProxy>;
			m_levelLoaded = true;
			if (!m_paused) togglePause();
		}

		public function refocus(focused:EditorProxy):void {
			if (m_focused) m_focused.loseFocus();
			m_focused = focused;
			while (m_menu.focusedRect.numChildren > 0)
				m_menu.focusedRect.removeChildAt(0);
			if (m_focused) {
				m_focused.gainFocus();
				m_menu.focusedCaption.text = "Selected: " 
					+ m_focused.getCaption();
				m_focused.populateForm(m_menu.focusedRect);
			} else {
				m_menu.focusedCaption.text = "Selected: None";
			}
		}

		public function togglePause():void {
			if (m_levelLoaded) {
				m_paused = !m_paused;
				m_level.setUpdatePhysics(!m_paused);
				if (!m_paused) {
					var blocks:Vector.<Block> = m_level.getBlocks();
					for (var i:uint=0;i<blocks.length;++i) {
						blocks[i].getPhysics().SetAwake(true);
					}
				}
				if (m_paused)
					EditorMenu.makeActiveButtonStates(m_menu.pauseButton,
						"Unpause (P)", 70, 12, m_menu.textButtonFormat);
				else 
					EditorMenu.makeButtonStates(m_menu.pauseButton, 
						"Pause (P)", 70, 12, m_menu.textButtonFormat);
			}
		}

		public function doReset():void {
			if (m_levelLoaded) {
				for (var i:uint=0;i<m_blocks.length;++i) {
					m_blocks[i].reposition();
					m_blocks[i].getBlock().resetCharge();
				}
				m_player.reposition();
				m_player.getPlayer().resetCharge();
			}
		}

		public function toggleWidgets():void {
			m_widgetsHidden = !m_widgetsHidden;
			for (var i:uint=0;i<m_blocks.length;++i) {
				m_blocks[i].visible = !m_widgetsHidden;
			}
			m_player.visible = !m_widgetsHidden;
		}
	}
}
