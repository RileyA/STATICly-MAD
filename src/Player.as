package {

	import Actioners.*;
	import GfxPhysObject;
	import flash.display.*;
	import flash.ui.Keyboard;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Chargable.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Collision.*;
	import Box2D.Common.Math.*;
	import Box2D.Collision.b2Collision;
	import Colors;

	public class Player extends GfxPhysObject implements Chargable {

		private static const DO_REACTION_FORCES:Boolean=true;

		private static const JUMP_STRENGTH:Number=7.8;
		private static const MOVE_SPEED:Number=6.0;
		private static const MOVE_AIR_SPEED:Number=4.0;
		private static const AIR_ACELL_TIME_CONSTANT:Number=0.5;
		private static const GROUND_ACELL_TIME_CONSTANT:Number=0.1;
		private static const SHUFFLE_INCREMENT_FACTOR:Number=0.1;
		private static const DENSITY:Number=20.0;
		private static const CHARGE_DENSITY:Number=1.5;

		public static const WIDTH:Number = 0.7;
		public static const HEIGHT:Number = -1.2;
		public static const HEIGHT_MID:Number = -0.9;
		public static const HEIGHT_CHARGE:Number = -0.5;
		public static const HEIGHT_ACTION:Number = -0.5;

		private var m_sprite:Sprite;
		public var chargePolarity:int;
		private var shuffleStrength:Number;
		private var didAction:Boolean; // true when already did action for this action button press
		private var charges:Vector.<Charge>;
		
		private var bestAction:ActionMarker;
		private var actionInd:Sprite; // on target of potential action
		private var actionMid:Sprite; // between player and action target
		private var actionHit:Sprite; // at player hit action target
		private var actionShape:b2PolygonShape;
		
		private var faceRight:Boolean;
		
		public function Player(level:Level, parentSprite:Sprite, position:UVec2):void {
			var world:b2World=level.world;
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsArray([new b2Vec2(0,HEIGHT),new b2Vec2(WIDTH/2,
				HEIGHT_MID), new b2Vec2(WIDTH/2,0),new b2Vec2(-WIDTH/2,0),
					new b2Vec2(-WIDTH/2,HEIGHT_MID)]);

			var fd:b2FixtureDef = new b2FixtureDef();
			var ccDef:b2BodyDef = new b2BodyDef();
			ccDef.type = b2Body.b2_dynamicBody;
			ccDef.allowSleep = false;
			ccDef.awake = true;
			ccDef.position = position.toB2Vec2();
			fd.shape = polyShape;
			fd.density = DENSITY;
			fd.friction = 0.0;
			fd.restitution = 0.0;
			fd.userData = LevelContactListener.PLAYER_BODY_ID;
			m_physics = world.CreateBody(ccDef);
			m_physics.CreateFixture(fd);
			m_physics.SetFixedRotation(true);
			m_physics.SetLinearDamping(.5);
			
			var area:Number=m_physics.GetMass()/fd.density;
			var chargeStrength:Number=area*CHARGE_DENSITY;
			this.charges=new Vector.<Charge>();
			this.charges.push(new Charge(chargeStrength,new b2Vec2(
								0,
								HEIGHT_CHARGE
							)));

			// placeholder sprite to be replaced with an animated MovieClip at some point...
			m_sprite = new Sprite();
			m_sprite.graphics.beginFill(0xBBBBBB);
			m_sprite.graphics.drawRect(-WIDTH/2.0, HEIGHT, WIDTH, -HEIGHT);
			m_sprite.graphics.endFill();
			addChild(m_sprite);
			
			groundPlayer();
			
			// make foot/jump sensor
			fd = new b2FixtureDef();
			fd.density=0;
			polyShape = new b2PolygonShape();
			polyShape.SetAsBox(WIDTH/3, 0.1);
			fd.shape = polyShape;
			fd.isSensor = true;
			fd.userData = LevelContactListener.FOOT_SENSOR_ID;
			m_physics.CreateFixture(fd);
			
			// make action sensor
			const m:Number=.15;//action region margin
			fd = new b2FixtureDef();
			fd.density=0;
			actionShape = new b2PolygonShape();
			actionShape.SetAsArray([new b2Vec2(0,HEIGHT-m),
				new b2Vec2(WIDTH/2+m,HEIGHT_MID-m),
				new b2Vec2(WIDTH/2+m,m),new b2Vec2(-WIDTH/2-m,m),
				new b2Vec2(-WIDTH/2-m,HEIGHT_MID-m)]);
			fd.shape = actionShape;
			fd.isSensor = true;
			fd.userData = LevelContactListener.PLAYER_ACTION_ID;
			m_physics.CreateFixture(fd);
			
			actionInd = new Sprite();
			actionInd.graphics.lineStyle(3.0, Colors.markerColor, .8, false, LineScaleMode.NONE);
			actionInd.graphics.moveTo(-.1, -.1);
			actionInd.graphics.lineTo(.1, .1);
			actionInd.graphics.moveTo(-.1, .1);
			actionInd.graphics.lineTo(.1, -.1);
			actionInd.graphics.endFill();
			
			actionMid = new Sprite();
			actionMid.graphics.lineStyle(3.0, Colors.markerColor, .8, false, LineScaleMode.NONE);
			actionMid.graphics.moveTo(-.1, -.1);
			actionMid.graphics.lineTo(.1, .1);
			actionMid.graphics.moveTo(-.1, .1);
			actionMid.graphics.lineTo(.1, -.1);
			actionMid.graphics.endFill();
			
			actionHit = new Sprite();
			actionHit.graphics.lineStyle(3.0, Colors.markerColor, .8, false, LineScaleMode.NONE);
			actionHit.graphics.moveTo(-.1, -.1);
			actionHit.graphics.lineTo(.1, .1);
			actionHit.graphics.moveTo(-.1, .1);
			actionHit.graphics.lineTo(.1, -.1);
			actionHit.graphics.endFill();
			
			parentSprite.addChild(this);
			
			parentSprite.addChild(actionInd);
			parentSprite.addChild(actionMid);
			parentSprite.addChild(actionHit);
		}
		
		private function doActionSprite(s:Sprite,pos:b2Vec2,pixelsPerMeter:Number):void{
			s.scaleX = pixelsPerMeter;
			s.scaleY = pixelsPerMeter;
			s.visible=true;
			s.x = pos.x * pixelsPerMeter;
			s.y = pos.y * pixelsPerMeter;
		}
		
		
		public override function updateTransform(pixelsPerMeter:Number):void {
			super.updateTransform(pixelsPerMeter);
			
			var marker:ActionMarker = getBestAction();
			if (marker != null) {

				var markerPos:b2Vec2 = marker.fixture.GetBody().GetPosition().Copy();
				doActionSprite(actionInd,markerPos,pixelsPerMeter);
				
				var pos:b2Vec2=m_physics.GetPosition().Copy();
				pos.y+=HEIGHT_ACTION;
				
				var midPos:b2Vec2=pos.Copy()
				midPos.Add(markerPos);
				midPos.Multiply(.5);
				doActionSprite(actionMid,midPos,pixelsPerMeter);
				
				var diff:b2Vec2=pos.Copy()
				diff.Subtract(markerPos);
				var dist:Number=diff.Normalize();
				var hitPos:b2Vec2=pos.Copy()
				if (dist>HEIGHT_ACTION){
					diff.Multiply(HEIGHT_ACTION);
					hitPos.Add(diff);
				}

				doActionSprite(actionHit,hitPos,pixelsPerMeter);
			} else {
				actionInd.visible=false;
				actionMid.visible=false;
				actionHit.visible=false;
			}
		}
		
		public function getBestAction():ActionMarker {
			function actionFilter(a:*,b:*):Boolean{
				return (a is ActionMarker && b==LevelContactListener.PLAYER_ACTION_ID);
			}
			var markers:Vector.<*>=PhysicsUtils.getCollosions(m_physics,actionFilter);
			
			
			
			function weight(a:ActionMarker):Number{
				var pos:b2Vec2=m_physics.GetLocalPoint(a.fixture.GetBody().GetPosition());
				if (!faceRight){
					pos.x=-pos.x;
				}
				pos.y=pos.y-HEIGHT_ACTION;
				pos.x=pos.x*4;
				return pos.x-Math.abs(pos.y);
			}
			
			function cmp(a:ActionMarker,b:ActionMarker):Number{
				return weight(b)-weight(a);
			}
			
			// TODO : Sort by priority/location
			markers.sort(cmp);
			// don't have fixture data
			// might need to reimplement getCollosions logic
			
			var i:int;
			for (i=0;i<markers.length;i++){
				if (markers[i].canAction(this)){
					return markers[i];
				}
			}
			
			return null;
		}
		
		public function update(level:Level):void {
			ChargableUtils.matchColorToPolarity(this, chargePolarity);
			
			var left:Boolean=Keys.isKeyPressed(Keyboard.LEFT);
			var right:Boolean=Keys.isKeyPressed(Keyboard.RIGHT);
			var up:Boolean=Keys.isKeyPressed(Keyboard.UP);
			var action:Boolean=Keys.isKeyPressed(Keyboard.DOWN);
			
			// no logical xor :(
			if ((left || right)&&!(left && right)) {
				faceRight=right;
			}


			var bestAction:ActionMarker = getBestAction();

			
			// do actions
			if ((!didAction) && action) {
				if (bestAction!=null) {
					bestAction.callAction(level);
					didAction=true;
				}
			} else if (!action) {
				didAction=false;
			}
			
			groundCollision(); // for grounding
			carpetCollision(left || right); // for chargeing
			
			// do movement //
			// get contacts with feet
			function jumpFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.JUMPABLE_ID && b==LevelContactListener.FOOT_SENSOR_ID;
			}
			
			var footContacts:Vector.<*>=PhysicsUtils.getCollosions(m_physics,jumpFilter,PhysicsUtils.OUT_EDGE);
			var canJump:Boolean=footContacts.length>0;
			
			// setup for reaction forces
			var reactBody:b2Body;
			var reactLoc:b2Vec2
			if (canJump && DO_REACTION_FORCES){
				var con0:b2ContactEdge=footContacts[0];
				reactBody=con0.other;
				reactLoc=m_physics.GetWorldPoint(new b2Vec2(0,0));
			}
			
			// x movement //
			var xspeed:Number = 0;
			if (left) { xspeed -= 1; }
			if (right) { xspeed += 1; }
			if (canJump) {
				xspeed*=MOVE_SPEED;
			} else {
				xspeed*=MOVE_AIR_SPEED;
			}
			
			if (canJump || xspeed!=0) {
				var fx:Number=m_physics.GetMass()/(canJump?GROUND_ACELL_TIME_CONSTANT:AIR_ACELL_TIME_CONSTANT);
				var vx:Number=m_physics.GetLinearVelocity().x;
				var deltaSpeed:Number=xspeed-vx;
				fx*=deltaSpeed;
				if (canJump || (deltaSpeed*xspeed)>0) {
					m_physics.ApplyForce(new b2Vec2(fx, 0),m_physics.GetWorldCenter());
					if (canJump && DO_REACTION_FORCES){
						reactBody.ApplyForce(new b2Vec2(-fx, 0),reactLoc);
					}
				}
			}
			
			// jumping
			if (up && canJump) {
				var fy:Number=m_physics.GetMass()*(m_physics.GetLinearVelocity().y+JUMP_STRENGTH);
				if (DO_REACTION_FORCES){
					reactBody.ApplyImpulse(new b2Vec2(0, fy),reactLoc);
				}
				m_physics.ApplyImpulse(new b2Vec2(0, -fy),m_physics.GetWorldCenter());
				// That should be the same as this:
				//m_physics.GetLinearVelocity().y=-JUMP_STRENGTH;
			}
		}
		
		private function groundCollision():void {
			function groundFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.GROUND_SENSOR_ID &&
					(b==LevelContactListener.FOOT_SENSOR_ID ||
					 b==LevelContactListener.PLAYER_BODY_ID );
			}
			var isGrounded:Boolean=PhysicsUtils.getCollosions(m_physics,groundFilter).length>0;
			
			if (isGrounded) {
				groundPlayer();
			}
		}

		private function carpetCollision(isMoving:Boolean):void {
			// Shuffling over carpet
			function carpetRedFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.CARPET_RED_SENSOR_ID && b==LevelContactListener.FOOT_SENSOR_ID;
			}
			var onCarpetRed:Boolean=PhysicsUtils.getCollosions(m_physics,carpetRedFilter).length>0;

			function carpetBlueFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.CARPET_BLUE_SENSOR_ID && b==LevelContactListener.FOOT_SENSOR_ID;
			}
			var onCarpetBlue:Boolean=PhysicsUtils.getCollosions(m_physics,carpetBlueFilter).length>0;

			var carpetPolarity:int = ChargableUtils.CHARGE_NONE;
			if (onCarpetRed)
				carpetPolarity = ChargableUtils.CHARGE_RED;
			if (onCarpetBlue)
				carpetPolarity = ChargableUtils.CHARGE_BLUE;


			shuffleCarpet(carpetPolarity, carpetPolarity != ChargableUtils.CHARGE_NONE && isMoving);
		}



		private function shuffleCarpet(carpetPolarity:Number, isShuffling:Boolean):void {
			var isCharged:Boolean = chargePolarity != ChargableUtils.CHARGE_NONE;
			shuffleStrength=Math.max(shuffleStrength,-1);
			shuffleStrength=Math.min(shuffleStrength,1);
			
			if (!isShuffling) {
				if (!isCharged && shuffleStrength != 0.0) {
					// If not shuffling, not charged, and shuffle strength is not zero
					// Decrement shuffle strength until it reaches zero
					if (shuffleStrength < 0)
						shuffleStrength = Math.max(0,shuffleStrength + SHUFFLE_INCREMENT_FACTOR);
					else
						shuffleStrength = Math.min(0,shuffleStrength - SHUFFLE_INCREMENT_FACTOR);
				} else if (isCharged && Math.abs(shuffleStrength) < 1.0) {
					// If we are charged, but shuffleStrength is not full
					// (e.g. half-assed shuffle on opposite carpet)
					// increment shuffle strength in direction of current polarity until it reaches full
					shuffleStrength += SHUFFLE_INCREMENT_FACTOR * chargePolarity;
				}
			} else if (chargePolarity != carpetPolarity) {  // is shuffling over non-same carpet
				if ((shuffleStrength * carpetPolarity) >= 1.0) {
					// We have reached full shuffle strength matching the current carpet. We are charged!
					chargePolarity = carpetPolarity;
				} else {
					// increment shuffle strength in direction of current carpet polarity
					shuffleStrength += SHUFFLE_INCREMENT_FACTOR * carpetPolarity;
				}
			}
		}

		public function groundPlayer():void {
			chargePolarity = ChargableUtils.CHARGE_NONE;
			shuffleStrength = 0.0;
			ChargableUtils.matchColorToPolarity(this, chargePolarity);
		}

		/**
		* Returns the charge of this Chargable for electrostatics computations.
		*/
		
		public function getCharge():Number{
			return chargePolarity;
		}
		
		public function getCharges():Vector.<Charge>{
			return charges;
		}

		/**
		* Returns the b2Body of this Chargable for physics operations.
		*/
		public function getBody():b2Body{
			return m_physics;
		}

		public function setPosition(pos:UVec2):void {
			m_physics.SetPosition(pos.toB2Vec2());
		}

		public function resetCharge():void {
			chargePolarity = 0;
		}
	}
}
