package {
	import starling.display.Sprite;
	import starling.events.Event;
	import flash.utils.getTimer;
	import flash.ui.Keyboard;
	import cse481d.Logger;
	import OverworldState;
	import flash.utils.Dictionary;
	import Config;
	import flash.net.SharedObject;
	
	/** Manages a stack of game states */
	public class Game extends Sprite {
		private var m_lastTime:Number;
		private var m_currentState:GameState;
		private var m_states:Vector.<GameState>;
		private var m_newStateReady:Boolean;
		private var m_menu:Menu;
		private var m_toggle:Boolean;
		
		private var m_overworlds:Dictionary; // name -> overworld

		/** Constructor */
		public function Game():void {
			m_overworlds = new Dictionary();
			//m_parent = parent;
			//m_parent.stage.stageFocusRect = false;
			m_lastTime = getTimer();
			m_currentState = null;
			m_states = new Vector.<GameState>;
			m_newStateReady = false;
			m_menu = new Menu();
			m_toggle = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		public function getOverworld(name:String):OverworldState{
			var x:OverworldState=m_overworlds[name];
			if (x==null) {
				x = new OverworldState(this, name);
				m_overworlds[name]=x;
			}
			return x;
		}

		protected function onAdded(e:Event):void {
			LoggerUtils.initLogger();
			if (Config.debug) {
				addState(getOverworld("DebugLab"));
				addState(new LevelState(this, "Intro", m_overworlds["DebugLab"]));
			} else if(Config.storage) {
				var so:SharedObject = SharedObject.getLocal("staticlyMad");
				if (so.size == 0) {
					so.data.last = "DischargeLab";
					so.data.completed = new Dictionary();
					addState(getOverworld("DischargeLab"));
					addState(new LevelState(this, "Intro", m_overworlds["DischargeLab"]));
				} else {
					//Config.logging = false;
					for (var levelName:String in so.data.completed) {
						var score:int = so.data.completed[levelName];
						var split:Array = levelName.split(/_/);
						getOverworld(split[0]).completed(split[1], score);
					}
					//Config.logging = true;
					addState(getOverworld(so.data.last));
				}
			} else {
				SharedObject.getLocal("staticlyMad").clear();
				addState(getOverworld("DischargeLab"));
				addState(new LevelState(this, "Intro", m_overworlds["DischargeLab"]));
			}
			update();
		}

		/** Adds a state 
				@param state The state to add */
		public function addState(state:GameState):void {
			m_states.push(state);
			m_newStateReady = true;
		}

		/** Replaces the current state 
				@param state The state to replace it with */
		public function replaceState(state:GameState):void {
			addState(state);
			terminate();
		}

		/** Update the game, advance a frame 
		  @return True if continuing as usual, false if out of
		  game states */
		public function update():Boolean {
			// timing
			var currentTime:Number = getTimer();
			var delta:Number = (currentTime - m_lastTime) / 1000.0;
			m_lastTime = currentTime;

			// a new state is at the top of the stack! let's init dat
			if (m_currentState == null || m_newStateReady) {

				m_newStateReady = false;

				var lastState:GameState = m_currentState;
				if (m_currentState) {
					m_currentState.suspend();
					this.removeChild(m_currentState);
				}

				if (m_states.length == 0)
					return false;

				m_currentState = m_states.pop();
				if (lastState) m_states.push(lastState);

				this.addChild(m_currentState);

				if (!m_currentState.initialized) {
					m_currentState.init();
					m_currentState.initialized = true;
				} else {
					m_currentState.resume();
				}
			}

			if (!m_currentState.update(delta)) {
				terminate();
			}

			if (Keys.isKeyPressed(Keyboard.M) && !m_toggle) {
				if (SoundManager.toggle()) {
					m_menu.unmute();
				}else {
					m_menu.mute();
				}
				m_toggle = true;
			}
			if (!Keys.isKeyPressed(Keyboard.M)) {
				m_toggle = false;
			}
			
			return true;
		}

		/**
		* Terminates the currently running state, removing it from the Game state machine
		*/
		public function terminate():void {
			this.removeChild(m_currentState);
			m_currentState.deinit();
			m_currentState = null;
		}

		public function getMenu():Menu {
			return m_menu;
		}

		public function getTotalScore():int {
			var total:int = 0;
			for(var name:String in m_overworlds){
				total += m_overworlds[name].getTotalScore();
			}
			return total;
		}
	}
}
