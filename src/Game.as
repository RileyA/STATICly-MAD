package {
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import GameState;

	/** Manages a stack of game states */
	public class Game {

		private var m_parent:Sprite;
		private var m_lastTime:Number;
		private var m_currentState:GameState;
		private var m_states:Vector.<GameState>;
		private var m_newStateReady:Boolean;

		/** Constructor
			@param parent Reference to parent sprite */
		public function Game(parent:Sprite):void {
			m_parent = parent;
			m_parent.stage.stageFocusRect = false;
			m_lastTime = getTimer();
			m_currentState = null;
			m_states = new Vector.<GameState>;
			m_newStateReady = false;
		}

		/** Adds a state 
				@param state The state to add */
		public function addState(state:GameState, start:Boolean = true):void {
			m_states.push(state);
			m_newStateReady = start;
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
					m_parent.removeChild(m_currentState);
				}

				if (m_states.length == 0)
					return false;

				m_currentState = m_states.pop();
				if (lastState) m_states.push(lastState);

				m_parent.addChild(m_currentState);

				if (!m_currentState.initialized) {
					m_currentState.init();
					m_currentState.initialized = true;
				} else {
					m_currentState.resume();
				}

				m_parent.stage.focus = m_currentState;
			}

			if (!m_currentState.update(delta)) {
				m_parent.removeChild(m_currentState);
				m_currentState.deinit();
				m_currentState = null;
			}

			return true;
		}
	}
}

