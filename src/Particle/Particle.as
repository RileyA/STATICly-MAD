package Particle {

	import starling.display.*;
	import starling.textures.Texture;

	public class Particle extends Image {

		public var x_velocity:Number;
		public var y_velocity:Number;
		public var lifespan:Number = 1.0;
		public var timeLived:Number = 0.0;
		public var follow:Boolean = false;

		public function Particle(tex:Texture, x_:Number=0, y_:Number=0, 
			w_:Number=10, h_:Number=10) :void {
			super(tex);
			x = x_;
			y = y_;
			width = w_;
			height = h_;
			x_velocity = 0;
			y_velocity = 0;
		}

		public function update(delta:Number):Boolean {
			timeLived += delta;
			if (timeLived > lifespan) return false;
			if (follow)
			{
				y_velocity += delta * 70;
				var v:Number = Math.sqrt(x_velocity*x_velocity 
					+ y_velocity*y_velocity);
				rotation = Math.atan2(y_velocity/v, x_velocity/v);
			}
			x += x_velocity * delta;
			y += y_velocity * delta;
			alpha = 1.0 - (timeLived / lifespan);
			return true;
		}
	}
}
