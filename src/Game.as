package {
	import starling.display.Sprite;
	import starling.events.Event;
	import flash.utils.getTimer;
	import cse481d.Logger;
	import OverworldState;
	import flash.utils.Dictionary;
	import Config;
	
	/** Manages a stack of game states */
	public class Game extends Sprite {
		private var m_lastTime:Number;
		private var m_currentState:GameState;
		private var m_states:Vector.<GameState>;
		private var m_newStateReady:Boolean;
		private var m_menu:Menu;
		
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
			} else {
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
				//m_parent.stage.focus = m_currentState;
			}

			if (!m_currentState.update(delta)) {
				terminate();
			}

			return true;
		}

		/**
		* Terminates the currently running state, removing it from the Game state machine
		*/
		private function terminate():void {
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
