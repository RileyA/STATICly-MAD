package {
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	public class BlockManager{
		private var blocks:Vector.<Block>;
		private var dynBlocks:Vector.<Block>;
		public var world:b2World;
		public function BlockManager(world:b2World):void{
			this.world=world;
			blocks=new Vector.<Block>();
			dynBlocks=new Vector.<Block>();
		}
		public function addBlock(b:Block):void{
			blocks.push(b);
			if (b.body.GetType()==b2Body.b2_dynamicBody) {
				dynBlocks.push(b);
			}
		}
		public function addForces():void{
			var i:int;
			var j:int;
			for (i=0;i<dynBlocks.length;i++){
				var forced:Block=dynBlocks[i];
				var force:b2Vec2= new b2Vec2(0,0);
				for (j=0;j<blocks.length;j++){
					var forcer:Block=blocks[j];
					if (forcer!=forced){
						var vec:b2Vec2 = forced.body.GetPosition();
						vec.Subtract(forcer.body.GetPosition());
						var s:Number=forcer.charge*forced.charge*(1.0/vec.LengthSquared());
						s=s*1000.0;
						vec.Multiply(s/vec.Length());
						force.Add(vec);
					}
				}
				forced.body.ApplyForce(force,forced.body.GetWorldCenter());
			}
		}
	}

}
