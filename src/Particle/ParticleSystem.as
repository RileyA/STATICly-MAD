package Particle {

	import starling.display.*;
	import starling.textures.Texture;
	import flash.utils.*;

	/** A particle system, can be loaded direct from JSON! */
	public class ParticleSystem extends Sprite {

		public var m_particles:Vector.<Particle>  
			= new Vector.<Particle>();
		public var m_emitters:Vector.<ParticleEmitter> 
			= new Vector.<ParticleEmitter>();
		public var m_affectors:Vector.<ParticleAffector> 
			= new Vector.<ParticleAffector>();
		
		public function ParticleSystem():void {
			
		}

		public function addParticle(p:Particle):void {
			addChild(p);
			m_particles.push(p);
		}

		public function addEmitter(e:ParticleEmitter):void {
			e.setSystem(this);
			m_emitters.push(e);
		}

		/** Update particles, affectors and emitters */
		public function update(delta:Number):Boolean {
			for (var i:uint = 0; i < m_particles.length; ++i) {
				if (!m_particles[i].update(delta)) {
					removeChild(m_particles[i]);
					// swap with last element and pop to erase
					if (i != m_particles.length - 1) {
						var tmp:Particle = m_particles[m_particles.length - 1];
						m_particles[i] = tmp;
					}
					m_particles.pop();
					--i;
				}
			}
			for (i = 0; i < m_emitters.length; ++i) {
				if (!m_emitters[i].update(delta)) {
					if (i != m_emitters.length - 1) {
						var temp:ParticleEmitter = m_emitters[
							m_emitters.length - 1];
						m_emitters[i] = temp;
					}
					m_emitters.pop();
					--i;
				}
			}

			return m_particles.length != 0 || m_emitters.length != 0;
		}
	}
}
