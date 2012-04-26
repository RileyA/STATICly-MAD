package {

	import Actioners.*;
	import GfxPhysObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;
	import flash.ui.Keyboard;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Chargable.Chargable;
	import Chargable.ChargableUtils;

	public class Player extends GfxPhysObject implements Chargable {

		private static const JUMP_STRENGTH:Number=8.0;
		private static const MOVE_SPEED:Number=6.0;
		private static const ACELL_TIME_CONSTANT:Number=0.5;
		private var chargeStrength:Number;
		private static const SHUFFLE_INCREMENT_FACTOR:Number=0.05;

		// Keyboard controls
		private static const LEFT_KEY:Number = Keyboard.LEFT;
		private static const RIGHT_KEY:Number = Keyboard.RIGHT;
		private static const JUMP_KEY:Number = Keyboard.UP;
		private static const ACTION_KEY:Number = Keyboard.DOWN;

		private var m_sprite:Sprite;
		public var chargePolarity:int;
		private var shuffleStrength:Number;
		private var didAction:Boolean; // true when already did action for this action button press
		
		
		

		public function Player(levelState:LevelState, position:UVec2):void {

			var polyShape:b2PolygonShape = new b2PolygonShape();
			const w:Number=.7;
			const h:Number=-1.2;
			const hMid:Number=-0.9;
			polyShape.SetAsArray([new b2Vec2(0,h),new b2Vec2(w/2,hMid),
				new b2Vec2(w/2,0),new b2Vec2(-w/2,0),new b2Vec2(-w/2,hMid)])

			var fd:b2FixtureDef = new b2FixtureDef();
			var ccDef:b2BodyDef = new b2BodyDef();
			ccDef.type = b2Body.b2_dynamicBody;
			ccDef.allowSleep = false;
			ccDef.awake = true;
			ccDef.position = position.toB2Vec2();
			fd.shape = polyShape;
			fd.density = Block.strongDensity*2;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			fd.userData = LevelContactListener.PLAYER_BODY_ID;
			m_physics = levelState.world.CreateBody(ccDef);
			m_physics.CreateFixture(fd);
			m_physics.SetFixedRotation(true);
			m_physics.SetLinearDamping(.2);
			
			var area:Number=m_physics.GetMass()/fd.density;
			chargeStrength=area*Block.strongChargeDensity;

			// placeholder sprite to be replaced with an animated MovieClip at some point...
			m_sprite = new Sprite();
			m_sprite.graphics.beginFill(0xBBBBBB);
			m_sprite.graphics.drawRect(-w/2.0, h, w, -h);
			m_sprite.graphics.endFill();
			addChild(m_sprite);
			
			groundPlayer();
			
			// make foot/jump sensor
			fd = new b2FixtureDef();
			polyShape = new b2PolygonShape();
			polyShape.SetAsBox(0.3, 0.2);
			fd.shape = polyShape;
			fd.isSensor = true;
			fd.userData = LevelContactListener.FOOT_SENSOR_ID;
			m_physics.CreateFixture(fd);
			
			// make action sensor
			const m:Number=.3;//action region margin
			fd = new b2FixtureDef();
			polyShape = new b2PolygonShape();
			polyShape.SetAsArray([new b2Vec2(0,h-m),new b2Vec2(w/2+m,hMid-m),
				new b2Vec2(w/2+m,m),new b2Vec2(-w/2-m,m),new b2Vec2(-w/2-m,hMid-m)])
			fd.shape = polyShape;
			fd.isSensor = true;
			fd.userData = LevelContactListener.PLAYER_ACTION_ID;
			m_physics.CreateFixture(fd);
		}
		
		
		public function getBestAction():ActionMarker {
			function actionFilter(a:*,b:*):Boolean{
				return (a is ActionMarker && b==LevelContactListener.PLAYER_ACTION_ID);
			}
			var markers:Vector.<*>=PhysicsUtils.getCollosions(m_physics,actionFilter);
			
			// TODO : Sort by priority/location
			// markers.sort(compare);
			
			var i:int;
			for (i=0;i<markers.length;i++){
				if (markers[i].canAction(this)){
					return markers[i];
				}
			}
			
			return null;
		}
		
		
		public function update(state:LevelState):void {
			ChargableUtils.matchColorToPolarity(this, chargePolarity);
			
			function groundFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.GROUND_SENSOR_ID &&
					(b==LevelContactListener.FOOT_SENSOR_ID ||
					 b==LevelContactListener.PLAYER_BODY_ID );
			}
			var isGrounded:Boolean=PhysicsUtils.getCollosions(m_physics,groundFilter).length>0;
			
			if (isGrounded) {
				groundPlayer();
			}
			
			function jumpFilter(a:*,b:*):Boolean{
				return a==LevelContactListener.JUMPABLE_ID && b==LevelContactListener.FOOT_SENSOR_ID;
			}
			var canJump:Boolean=PhysicsUtils.getCollosions(m_physics,jumpFilter).length>0;
			
			
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
			
			var left:Boolean=Keys.isKeyPressed(Keyboard.LEFT);
			var right:Boolean=Keys.isKeyPressed(Keyboard.RIGHT);
			var up:Boolean=Keys.isKeyPressed(Keyboard.UP);
			var action:Boolean=Keys.isKeyPressed(Keyboard.DOWN);
			
			// do actions
			if ((!didAction) && action) {
				var marker:ActionMarker=getBestAction();
				if (marker!=null) {
					marker.callAction(state);
					didAction=true;
				}
			} else if (!action) {
				didAction=false;
			}
			
			// do movement
			var xspeed:Number = 0;
			if (left) { xspeed -= MOVE_SPEED; }
			if (right) { xspeed += MOVE_SPEED; }
			shuffleCarpet(carpetPolarity, carpetPolarity != ChargableUtils.CHARGE_NONE && (left || right));

			if (canJump) {
				m_physics.GetLinearVelocity().x=xspeed;
			} else if (xspeed!=0) {
				
				var fx:Number=m_physics.GetMass()/ACELL_TIME_CONSTANT;
				var vx:Number=m_physics.GetLinearVelocity().x;
				var deltaSpeed:Number=xspeed-vx;
				fx*=deltaSpeed;
				if ((deltaSpeed*xspeed)>0) {
					m_physics.ApplyForce(new b2Vec2(fx, 0),m_physics.GetWorldCenter());
				}
			}
			
			if (up && canJump) {
				m_physics.GetLinearVelocity().y=-JUMP_STRENGTH;
			}
		}

		private function shuffleCarpet(carpetPolarity:Number, isShuffling:Boolean):void {
			var isCharged:Boolean = chargePolarity != ChargableUtils.CHARGE_NONE;
			if (!isShuffling) {
				if (!isCharged && shuffleStrength != 0.0) {
					// If not shuffling, not charged, and shuffle strength is not zero
					// Decrement shuffle strength until it reaches zero
					if (shuffleStrength < 0)
						shuffleStrength += SHUFFLE_INCREMENT_FACTOR;
					else
						shuffleStrength -= SHUFFLE_INCREMENT_FACTOR;
				} else if (isCharged && shuffleStrength < 1.0) {
					// If we are charged, but shuffleStrength is not full
					// (e.g. half-assed shuffle on opposite carpet)
					// increment shuffle strength in direction of current polarity until it reaches full
					shuffleStrength += SHUFFLE_INCREMENT_FACTOR * chargePolarity;
				}
			} else if (chargePolarity != carpetPolarity) {  // is shuffling over non-same carpet
				if ((int)(shuffleStrength * carpetPolarity) == 1) {
					// We have reached full shuffle strength matching the current carpet. We are charged!
					chargePolarity = carpetPolarity;
					ChargableUtils.matchColorToPolarity(this, chargePolarity);
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
			return chargePolarity*chargeStrength;
		}

		/**
		* Returns the b2Body of this Chargable for physics operations.
		*/
		public function getBody():b2Body{
			return m_physics;
		}
	}
}
