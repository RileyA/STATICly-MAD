package {
	import starling.text.TextField;
	import flash.ui.Keyboard;
	import Particle.*;
	import starling.core.Starling;

	/** Simple placeholder menu state with a button that starts another state */
	public class ScoreState extends GameState {
		public static const COMPLETION_BONUS:int = 200;
		public static const TIME_FACTOR:int = 10;

		private var m_score:ScoreInfo;
		private var m_textFields:Vector.<TextField>;
		private var player_time:Number;
		private var under_par_time:Number;
		private var score:int;
		private var total:int;
		public var m_particles:Vector.<ParticleSystem> 
			= new Vector.<ParticleSystem>();
		private var sparkTimer:Number;

		public function ScoreState(game:Game, m_score:ScoreInfo):void {
			super(game);
			this.m_score = m_score;
			this.m_textFields = new Vector.<TextField>();
			player_time = MiscUtils.setPrecision(m_score.playerTime, 0);
			under_par_time = MiscUtils.setPrecision(m_score.targetTime, 0) - player_time;
			under_par_time = Math.max(under_par_time, 0);
			score = under_par_time * TIME_FACTOR;
			total = score + COMPLETION_BONUS;

			m_score.score = total;
		}

		override public function init():void {
			m_game.getMenu().attachTo(this);

			var fontSize:int = 24;
			var fontColor:uint = 0xBBBBBB;
			var fontStyle:String = "akashi"
			
			var hello_text:TextField = new TextField(800, 100, 
				"Cleared!\n", fontStyle, fontSize*1.5, fontColor);
			hello_text.x = 0;
			hello_text.y = 100;
			hello_text.hAlign = "center"
			addChild(hello_text);
			m_textFields.push(hello_text);
			
			var player_column_text:TextField = new TextField(400, 400, 
				"Completion Bonus:\nYour Time:\nTime Under Par:\nTime Score:\n\nTotal Score:\nPrevious Best:", 
				fontStyle, fontSize, fontColor);
			player_column_text.x = 150;
			player_column_text.y = 150;
			player_column_text.hAlign = "left";
			addChild(player_column_text);
			m_textFields.push(player_column_text);
			
			var score_column_text:TextField = new TextField(200, 400,
				COMPLETION_BONUS + "\n(" + player_time + ")s\n(" + under_par_time + ")s\n" + score + "\n\n" + total + "\n" + m_score.prevScore, 
				fontStyle, fontSize, fontColor);
			score_column_text.x = 400;
			score_column_text.y = 150;
			score_column_text.hAlign = "right";
			addChild(score_column_text);
			m_textFields.push(score_column_text);

			
			var editor_text:TextField = new TextField(600, 100, 
				"(ENTER) to Continue!\n", fontStyle, fontSize, fontColor);
			editor_text.x = 100;
			editor_text.y = 450;
			editor_text.hAlign = "center";
			addChild(editor_text);
			m_textFields.push(editor_text);

			// hackity hack..
			for (var i:uint = 0; i < m_textFields.length; ++i) {
				m_textFields[i].autoScale = true;
			}

			var numFx:uint = 5 + Math.round(Math.random() * 10);
			for (i = 0; i < numFx; ++i) 
				addSpark(4.0 + Math.random() * 4);
			sparkTimer = 0.3;
		}

		override public function deinit():void {
			m_game.getMenu().removeFrom(this);

			for(var i:int = 0; i < m_textFields.length; i++) {
				removeChild(m_textFields[i]);
			}
		}

		override public function update(delta:Number):Boolean {
			for (var i:uint = 0; i < m_particles.length; ++i) {
				if (!m_particles[i].update(delta)) {
					removeChild(m_particles[i]);
					if (i != m_particles.length - 1) {
						var tmp:ParticleSystem = m_particles[
							m_particles.length - 1];
						m_particles[i] = tmp;
					}
					m_particles.pop();
					--i;
				}
			}
			sparkTimer -= delta;
			if (sparkTimer < 0.0) {
				addSpark();
				sparkTimer = Math.random()*0.2 + 0.2;
			}
			return !Keys.isKeyPressed(Keyboard.ENTER);
		}

		public function addSpark(scaleFactor:Number = 1.0) :void {
			var x:Number = (Math.random() * 0.8 + 0.1) 
				* (Starling.current.viewPort.width);
			var y:Number = (Math.random() * 0.8 + 0.1) 
				* (Starling.current.viewPort.height);
			var scale:Number = scaleFactor * (100 + Math.random() * 100);
			var blue:Boolean = Math.random() > 0.5;
			var particleSys:ParticleSystem = new ParticleSystem();
			var emitter:ParticleEmitter = new ParticleEmitter();
			emitter.setTexture(blue ? MiscUtils.sparkTex_bs : MiscUtils.sparkTex_rs);
			particleSys.addEmitter(emitter);
			particleSys.x = x;
			particleSys.y = y;
			scale = scale;

			var mp:Particle = new Particle(blue ? MiscUtils.sparkTex_b	
				: MiscUtils.sparkTex_r);
			mp.width = scale;
			mp.height = scale;
			mp.x = -scale / 2;
			mp.y = -scale / 2;
			mp.lifespan = 0.3;
			particleSys.addParticle(mp);

			m_particles.push(particleSys);
			addChild(particleSys);
		}
	}
}
