package {
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import GameState;

	/** Manages a queue of game states */
	public class Game {

		private var m_parent:Sprite;
		private var m_lastTime:Number;
		private var m_currentState:GameState;
		private var m_states:Vector.<GameState>;

		/** Constructor */
		public function Game(par:Sprite):void {
			m_parent = par;
			m_lastTime = getTimer();
			m_currentState = null;
			m_states = new Vector.<GameState>;
		}

		/** Adds a state 
				@param state The state to add */
		public function addState(state:GameState):void {
			m_states.push(state);
		}

		/** Update the game, advance a frame 
				@return True if continuing as usual, false if out of
					game states */
		public function update():Boolean {
			// timing
			var currentTime:Number = getTimer();
			var delta:Number = (currentTime - m_lastTime) / 1000.0;
			m_lastTime = currentTime;

			if (!m_currentState) {
				// out of states, we're done!
				if (m_states.length == 0)
					return false;
				// otherwise grab the next state
				m_currentState = m_states.shift();
				m_currentState.init();
				m_parent.addChild(m_currentState);
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

