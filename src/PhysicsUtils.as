package {

	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Contacts.*;

	/** A set of constants and helpers for box2d stuffs */
	public class PhysicsUtils {
		public static function getCollosions(body:b2Body,filterFunc:Function):Vector.<*> {
			var v:Vector.<*>= new Vector.<*>;
			var con:b2ContactEdge=body.GetContactList();
			while (con!=null){
				var c:b2Contact=con.contact;
				if (c.IsTouching()){
					var a:*=c.GetFixtureA().GetUserData();
					var b:*=c.GetFixtureB().GetUserData();
					if (filterFunc(a,b)) {
						v.push(a);
					} else if (filterFunc(b,a)) {
						v.push(b);
					}
				}
				con=con.next;
			}
			return v;
		}
	}
}
