package {

	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Contacts.*;

	/** A set of constants and helpers for box2d stuffs */
	public class PhysicsUtils {
		public static const OUT_USER_DATA:int=0;
		public static const OUT_EDGE:int=1;
		public static function getCollosions(body:b2Body,filterFunc:Function,out:int=OUT_USER_DATA):Vector.<*> {
			var v:Vector.<*>= new Vector.<*>;
			var con:b2ContactEdge=body.GetContactList();
			while (con!=null){
				var c:b2Contact=con.contact;
				if (c.IsTouching()){
					var a:*=c.GetFixtureA().GetUserData();
					var b:*=c.GetFixtureB().GetUserData();
					if (filterFunc(a,b)) {
						if (out==OUT_USER_DATA){
							v.push(a);
						} else if (out==OUT_EDGE){
							v.push(con);
						} else {
							throw new Error("Pass a valid out constant");
						}
					} else if (filterFunc(b,a)) {
						if (out==OUT_USER_DATA){
							v.push(b);
						} else if (out==OUT_EDGE){
							v.push(con);
						} else {
							throw new Error("Pass a valid out constant");
						}
					}
				}
				con=con.next;
			}
			return v;
		}
	}
}
