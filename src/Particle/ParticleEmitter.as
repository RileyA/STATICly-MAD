package Particle {

	import starling.display.*;
	import starling.textures.Texture;

	/** Basic point emitter */
	public class ParticleEmitter {

		public var lifespan:Number = 0.1;
		public var particlesPerSecond:Number = 200;

		// properties of emitted particles
		public var min_lifespan:Number = 0.5;
		public var max_lifespan:Number = 1.0;
		public var min_v:Number = 50.0;
		public var max_v:Number = 100.0;
		public var min_rotation:Number = 0.0;
		public var max_rotation:Number = Math.PI * 2;
		public var min_size:Number = 4.0;
		public var max_size:Number = 8.0;

		private var system:ParticleSystem = null;
		private var nextParticle:Number = 1.0 / particlesPerSecond;
		private var tex:Texture = null;

		public function ParticleEmitter():void {
		}

		public function setTexture(t:Texture):void {
			tex = t;
		}

		public function setSystem(sys:ParticleSystem):void {
			system = sys;
		}

		public function update(delta:Number):Boolean {
			lifespan -= delta;
			if (lifespan <= 0.0)
				return false;

			while (delta > 0 && delta >= nextParticle) {
				delta -= nextParticle;
				nextParticle = 1.0 / particlesPerSecond;

				// make a particle
				emit();
			}
			nextParticle -= delta;
			return true;
		}

		public function emit():void {
			var p:Particle = new Particle(tex);
			p.x_velocity = Math.random() - 0.5;
			p.y_velocity = Math.random() - 0.5;
			var len:Number = Math.sqrt(p.x_velocity * p.x_velocity 
				+ p.y_velocity * p.y_velocity);
			var vel:Number = min_v + Math.random() * (max_v - min_v);
			p.x_velocity *= vel / len;
			p.y_velocity *= vel / len;
			p.width = p.height = min_size + Math.random() 
				* (max_size - min_size);
			p.lifespan = min_lifespan + Math.random() * (max_lifespan 
				- min_lifespan);
			system.addParticle(p);
		}
	}
}
