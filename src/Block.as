package {
	import Box2D.Dynamics.Joints.*;
	import starling.display.*;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import Surfaces.*;
	import Actioners.*;
	import Chargable.*;
	import starling.utils.Color;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import starling.textures.Texture;

	public class Block extends GfxPhysObject implements Chargable {
		
		[Embed(source = "../media/images/Rivet.png")]
		private static const n_rivit:Class;
		private static const rivitTex:Texture=Texture.fromBitmap(new n_rivit);
		
		[Embed(source = "../media/images/Circuit.png")]
		private static const n_circuits:Class;
		private static const circuitsTex:Texture=Texture.fromBitmap(new n_circuits);
		{
			circuitsTex.repeat=true;
		}

		/*[Embed(source = "../media/images/Circuit2.png")]
		private static const n_circuits2:Class;
		private static const circuitsTex2:Texture=Texture.fromBitmap(new n_circuits2);
		{
			circuitsTex2.repeat=true;
		}*/

		[Embed(source = "../media/images/galvanized.png")]
		private static const n_galv:Class;
		private static const galvTex:Texture=Texture.fromBitmap(new n_galv);
		{
			galvTex.repeat=true;
		}

		[Embed(source = "../media/images/cement1.png")]
		private static const n_cement:Class;
		private static const cementTex:Texture=Texture.fromBitmap(
			new n_cement);{cementTex.repeat=true;}
		
		[Embed(source = "../media/images/pipe.png")]
		private static const n_pipe:Class;
		private static const pipeTex:Texture=Texture.fromBitmap(new n_pipe);
		{
			pipeTex.repeat=true;
		}
		
		
		public static const FREE:String = "free";
		public static const TRACKED:String = "tracked";
		public static const FIXED:String = "fixed";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		
		private var movement:String;
		private var scale:UVec2;
		private var surfaces:Vector.<SurfaceElement>;
		private var actioners:Vector.<ActionerElement>;
		private var sprite:Quad;
		private var overlay:Image;
		private var anchor:Sprite;
		private var joints:Vector.<b2Joint>;
		private var hinting:Boolean=false;
		private var hintPhase:Number=0;
		private var chargeStrength:Number;

		private var eField:QuadBatch = null;
		private var eFieldScaleX:Number = 0;
		private var eFieldScaleY:Number = 0;
		
		// for charge
		public static const strongChargeDensity:Number = 2.0; // charge per square m
		public static const weakChargeDensity:Number = 1.0; // charge per square m

		public static const strongDensity:Number = 20.0; // kg per square m
		public static const weakDensity:Number = 12.0; // kg per square m
		
		private var chargePolarity:int;
		private var drawnChargePolarity:int;
		
		private var strong:Boolean;
		private var insulated:Boolean;
		
		private var charges:Vector.<Charge>;
		
		private var anchorBody:b2Body;

		// somewhat hacky... but it prevents having to pass the level in
		// when reinit-ing blocks in the editor, and presumably a block
		// will only ever belong to a single level at once...
		private var m_level:Level = null;
		private var m_info:BlockInfo;
		private var ppm:Number;
		
		/**
		 * @param	blockInfo Info struct containing various block properties
		 * @param	level The level this block lives in
		 */
		public function Block(blockInfo:BlockInfo, level:Level, ppm:Number=1)
			:void {
			this.ppm = ppm;
			m_level= level;
			m_info = blockInfo;
			init();
		}
		
		public function spark():void{
			var pos:b2Vec2= m_physics.GetPosition().Copy();
			var actionPos:b2Vec2=m_level.getPlayer().getActionPos();
			pos.Subtract(actionPos);
			pos.Normalize();
			pos.Add(actionPos);
			m_level.addSpark(pos.x, pos.y,  Math.sqrt(chargeStrength)*1.2, true, chargePolarity == 1);
		}
		
		public function init():void {

			joints = new Vector.<b2Joint>();
			surfaces = new Vector.<SurfaceElement>();
			actioners = new Vector.<ActionerElement>();

			var position:UVec2 = m_info.position.getCopy();
			scale = m_info.scale.getCopy();
			movement = m_info.movement;
			insulated=m_info.insulated;
			chargePolarity=m_info.chargePolarity;
			strong=m_info.strong&&(chargePolarity!=0||!insulated);
			
			var polyShape:b2PolygonShape = new b2PolygonShape();
			polyShape.SetAsBox(scale.x / 2, scale.y / 2);

			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = movement != FIXED 
				? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
			rectDef.position.Set(position.x, position.y);
			rectDef.angle = 0.0;
			m_physics = m_level.world.CreateBody(rectDef);

			var fd:b2FixtureDef = new b2FixtureDef();
			fd.shape = polyShape;
			fd.density = strong?strongDensity:weakDensity;
			fd.friction = 0.3;
			fd.restitution = 0.0;
			fd.userData = LevelContactListener.JUMPABLE_ID;
			m_physics.CreateFixture(fd);
			
			var area:Number=scale.x*scale.y;//m_physics.GetMass()/fd.density;
			chargeStrength=area*(strong?strongChargeDensity:weakChargeDensity);
			this.charges=ChargableUtils.makeCharges(chargeStrength, -scale.x / 2, -scale.y / 2, scale.x / 2, scale.y / 2);
			
			// make block actionable
			if (!insulated){
				function act(m_level:Level):void{
					SoundManager.play("zap2");
					var player:Player= m_level.getPlayer();
					if (strong) {
						if (chargePolarity==-player.chargePolarity) {
							spark();
							chargePolarity=ChargableUtils.CHARGE_NONE;
							player.groundPlayer();
						} else {
							if (player.chargePolarity==0) spark();
							var tmp:int=player.chargePolarity;
							player.chargePolarity=chargePolarity;
							chargePolarity=tmp;
							if (player.chargePolarity==0) spark();
						}
						
					} else { // make weak block copy players state, even if no charge
						if (player.chargePolarity == 0) {
							spark();
							chargePolarity=player.chargePolarity;
						} else {
							chargePolarity=player.chargePolarity;
							spark();
						}
					}
					LoggerUtils.logChargeBlock(player.chargePolarity, chargePolarity, strong);
				}
				function ck(player:Player):Boolean{ return chargePolarity!=player.chargePolarity;}
				fd.density=0;
				var fix:b2Fixture=m_physics.CreateFixture(fd);
				
				var that:Block=this;
				function startHint():void {
					hinting=true;
					hintPhase=0;
				}
				function endHint():void {
					hinting=false;
					hintPhase=0;
				}
				
				
				fix.SetUserData(new ActionMarker(act,ck,fix,this,startHint,endHint));
				
			}
			
			//body.SetFixedRotation(true);
			m_physics.SetLinearDamping(1.0);
			m_physics.SetAngularDamping(1.0);

			if (!insulated || chargePolarity != 0) {
				makeField();
			}

			if (insulated && chargePolarity != 0 && false) {
				sprite = new Image(galvTex); 
				sprite.width = scale.x;
				sprite.height = scale.y;
			} else {
				sprite = new Quad(scale.x, scale.y); 
			}

			sprite = new Quad(scale.x, scale.y);
			sprite.x = -scale.x / 2;
			sprite.y = -scale.y / 2;
			addChild(sprite);
			
			function image(x:Number,y:Number,w:Number,h:Number,t:Texture):Image{
				var s:Image=new Image(t);
				s.height=h;
				s.width=w;
				s.x=x-scale.x / 2;
				s.y=y-scale.y / 2;
				addChild(s);
				return s;
			}
			
			var scalar:Number=strong?.5:0.8;
			var offx:Number=Math.random();
			var offy:Number=Math.random();

			if (insulated && chargePolarity == 0) {
				scalar = 0.8;
				offx = 0;
				offy = 0;
			}
			const thick:Number=0.1;
			
			if (!insulated && isChargableBlock()){
				overlay=image(0,0,scale.x,scale.y,circuitsTex);
			} else if(insulated && chargePolarity == 0) {
				overlay=image(0,0,scale.x,scale.y,cementTex);
			} else {
				scalar *= 2.0;
				overlay=image(thick,thick,scale.x - thick*2,scale.y - thick*2,galvTex);
			}

			if ((insulated && chargePolarity != 0)) {
				scalar = insulated ? 1 : 0.75;
				overlay.setTexCoords(3,new Point(Math.max(1, Math.round(scale.x*scalar)),Math.max(1, Math.round(scale.y*scalar))));
				overlay.setTexCoords(1,new Point(Math.max(1, Math.round(scale.x*scalar)),0));
				overlay.setTexCoords(2,new Point(0,Math.max(1, Math.round(scale.y*scalar))));
				overlay.setTexCoords(0,new Point(0,0));
			} else {
				overlay.setTexCoords(3,new Point(scale.x*scalar+offx,scale.y*scalar+offy));
				overlay.setTexCoords(1,new Point(scale.x*scalar+offx,0+offy));
				overlay.setTexCoords(2,new Point(0+offx,scale.y*scalar+offy));
				overlay.setTexCoords(0,new Point(0+offx,0+offy));
			}
			
			function side(x:Number,y:Number,w:Number,h:Number):void{
				var s:Quad=new Quad(w, h, insulated?Colors.insulation:Colors.edges);
				s.x=x-scale.x / 2;
				s.y=y-scale.y / 2;
				if (!insulated || (insulated && chargePolarity == 0)){
					s.alpha= (insulated && chargePolarity == 0) ? 
						Colors.cementAlpha : Colors.edgeAlpha;
				}
				addChild(s);
			}

			side(0,0,thick,scale.y);
			side(scale.x-thick,0,thick,scale.y);
			side(thick,0,scale.x-thick*2,thick);
			side(thick,scale.y-thick,scale.x-thick*2,thick);
			
			function corner(x:Number,y:Number):void{
				image(x,y,cornerSize,cornerSize,rivitTex);
			}
			const cornerSize:Number=.4;
			if (movement == FIXED && !(insulated && !chargePolarity)){
				corner(0,0);
				corner(scale.x-cornerSize,0);
				corner(scale.x-cornerSize,scale.y-cornerSize);
				corner(0,scale.y-cornerSize);
			}

			redraw();
			

			var i:int = 0;

			for (i = 0; i < m_info.surfaces.length; i++) {
				rectDef.position.Set(position.x, position.y);
				addSurface(m_info.surfaces[i], rectDef, m_level.world);
			}
			for (i = 0; i < m_info.actions.length; i++) {
				rectDef.position.Set(position.x, position.y);
				addActioner(m_info.actions[i], rectDef, m_level.world);
			}
			
			anchor = null;
			if (movement == TRACKED) {
				makeTracked(m_info.bounds);
				m_level.m_backgroundLayer.addChild(anchor);
				//m_level.m_gfxPhysObjects.push(anchor);
			}
		}

		// helper that cleans up a block
		public function deinit():void {
			
			if (movement == FIXED) {
				m_level.m_staticChargeLayer.removeChild(eField);
			}
			else 
				m_level.m_dynamicChargeLayer.removeChild(eField);
			eField = null;
			
			for (var i:uint = 0; i < surfaces.length; ++i)
				surfaces[i].cleanup();
			for (i = 0; i < actioners.length; ++i)
				actioners[i].cleanup();
			var world:b2World = m_physics.GetWorld();
			world.DestroyBody(m_physics);
			m_physics = null;
			for (i = 0; i < joints.length; ++i)
				world.DestroyJoint(joints[i]);
			while (numChildren > 0)
				removeChildAt(0);
			joints = new Vector.<b2Joint>();
			surfaces = new Vector.<SurfaceElement>();
			actioners = new Vector.<ActionerElement>();
			if(anchor != null){
				m_level.m_backgroundLayer.removeChild(anchor);
				anchor = null;
			}
		}

		/** deinit and reinit to reflect any changes in blockinfo */
		public function reinit():void {
			deinit();
			// if it's in the charge manager, nuke it
			m_level.getChargableManager().removeChargable(this);
			
			init();
			
			// then re-add if need be
			if (isChargableBlock())
				m_level.getChargableManager().addChargable(this);
		}

		public function resetCharge():void {
			chargePolarity = m_info.chargePolarity;
		}

		public function getInfo():BlockInfo {
			return m_info;
		}
		
		private var m_hackLastPos:b2Vec2; // for hacking stupid track bug
		public override function updateTransform(pixelsPerMeter:Number):void {
			if (hinting){
				hintPhase+=.5; // TODO make frame rate independant;
			}
			overlay.alpha=.2+.8*((Math.sin(hintPhase)+1)/2);
			
			super.updateTransform(pixelsPerMeter);
			if (drawnChargePolarity!=chargePolarity) {
				redraw();
			}
			if (anchor != null) {
				//anchor.updateTransform(pixelsPerMeter);
				anchor.scaleX = pixelsPerMeter;
				anchor.scaleY = pixelsPerMeter;
				 //if physics object is null, just reset to origin...
				if (m_physics != null) {
					var apos:b2Vec2 = anchorBody.GetPosition();
					anchor.x = apos.x * pixelsPerMeter;
					anchor.y = apos.y * pixelsPerMeter;
				
				
					// start hacking stupid track bug
					if (m_hackLastPos != null) {
						m_hackLastPos.Subtract(m_physics.GetPosition());
						if (m_hackLastPos.LengthSquared()<.0000001) {
							m_physics.GetLinearVelocity().Multiply(.8);
						}
					}
					m_hackLastPos=m_physics.GetPosition().Copy();
					// end hacking stupid track bug
				}
				
			}
			if (eField != null /*&& movement != FIXED*/ && chargePolarity != 0) {
				eField.scaleX = pixelsPerMeter;
				eField.scaleY = pixelsPerMeter;
				//eField.rotation = rotation;
				eField.x = x-(eFieldScaleX/2)*pixelsPerMeter;
				eField.y = y-(eFieldScaleY/2)*pixelsPerMeter;
			}
		}

		public function setPosition(pos:UVec2):void {
			m_physics.SetPosition(pos.toB2Vec2());
			m_physics.SetAwake(true);
		}

		public function clearVelocity():void {
			m_physics.SetLinearVelocity(new b2Vec2(0,0));
			m_physics.SetAngularVelocity(0.0);
			m_physics.SetAngle(0);
		}

		public function getScale():UVec2 {
			return scale.getCopy();
		}
		
		public function getMovement():String {
			return movement;
		}
		
		
		private function redraw():void{
			var main:uint=0xFF;
			var off:uint=strong?0x05:0xA0;
			var overlayoff:uint=strong?0x40:0xDD;
			
			const blue:uint = Color.rgb(off,off,main);
			const none:uint = strong?0x888888:0xFFFFFF;
			const red:uint =  Color.rgb(main,off,off);
			
			const overlayblue:uint = Color.rgb(overlayoff,overlayoff,main);
			const overlaynone:uint = strong?0xD98719:0xEDC3B3;
			const overlayred:uint =  Color.rgb(main,overlayoff,overlayoff);

			switch (chargePolarity) {
			case ChargableUtils.CHARGE_BLUE:
				sprite.color = blue;
				if (overlay!=null) overlay.color=overlayblue;
				break;
			case ChargableUtils.CHARGE_RED:
				sprite.color = red;
				if (overlay!=null) overlay.color=overlayred;
				break;
			default:
				sprite.color = none;
				if (overlay!=null) overlay.color=overlaynone;
				break;
			}
			drawnChargePolarity=chargePolarity;

			if (eField) {
				if (movement == FIXED)
					m_level.m_staticChargeLayer.removeChild(eField);
				else
					m_level.m_dynamicChargeLayer.removeChild(eField);
				eField = null;
			}

			if (chargePolarity != 0)
				makeField();
			//m_level.m_staticChargeLayer.flatten();
			
			/*if (eField) {
				eField.visible = chargePolarity != 0;
			}*/
				
		}
		
		public function getCharge():Number{
			return chargePolarity;
		}
		
		public function getCharges():Vector.<Charge>{
			return charges;
		}
		
		public function getBody():b2Body{
			return m_physics;
		}

		public function isChargableBlock():Boolean {
			return !(chargePolarity == ChargableUtils.CHARGE_NONE && insulated)
		}
		
		private function addSurface(key:String, rectDef:b2BodyDef, world:b2World):void {
			var split:int = key.search(",");
			var dir:String = key.substr(0, split);
			var type:String = key.substr(split + 1, key.length);
			var se:SurfaceElement;

			switch (dir) {
			case UP:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(0, -scale.y / 2), 
													scale.x, SurfaceElement.DEPTH, world);			
				break;
			case DOWN:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(0, scale.y / 2), 
													scale.x, SurfaceElement.DEPTH, world);
				break;
			case LEFT:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(-scale.x / 2, 0), 
													SurfaceElement.DEPTH, scale.y, world);
				break;
			case RIGHT:
				se = SurfaceElement.getRelatedType(type, rectDef, new b2Vec2(scale.x / 2, 0), 
													SurfaceElement.DEPTH, scale.y, world);
				break;
			default:
				se == null;
			}
			if(se != null) {
				var joint:b2WeldJointDef = new b2WeldJointDef();
				joint.Initialize(m_physics, se.getPhysics(), rectDef.position);
				joints.push(world.CreateJoint(joint));
				surfaces.push(se);
				addChild(se);
			}
		}

		private function addActioner(key:String, rectDef:b2BodyDef, world:b2World):void {
			var tokens:Array = key.split(",");
			var dir:String = tokens[0];
			var type:String = tokens[1];
			var extra:Array = tokens.slice(2);
			var ae:ActionerElement;

			switch (dir) {
			case UP:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(0, -scale.y / 2), extra, world);
				break;
			case DOWN:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(0, scale.y / 2), extra, world);
				break;
			case LEFT:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(-scale.x / 2, 0), extra, world);
				break;
			case RIGHT:
				ae = ActionerElement.getRelatedType(type, rectDef, new b2Vec2(scale.x / 2, 0), extra, world);
				break;
			default:
				ae == null;
			}
			if(ae != null) {
				var joint:b2WeldJointDef = new b2WeldJointDef();
				joint.Initialize(m_physics, ae.getPhysics(), rectDef.position);
				joints.push(world.CreateJoint(joint));
				actioners.push(ae);
				addChild(ae);
			}
		}

		private function removeActions():void {
			// TODO
		}
		
		private function makeTracked(ends:Vector.<UVec2>):void {
			
			
			var center:b2Vec2 = m_physics.GetPosition().Copy();
			var trackDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			
			
			
			var slope:b2Vec2 = ends[0].toB2Vec2();
			slope.Normalize();
			var weights:b2Vec2 = ends[1].toB2Vec2();
			
			if (weights.x > weights.y) {
				var hold:Number = weights.y;
				weights.y = weights.x;
				weights.x = hold;
			}
			
			var l:b2Vec2 = new b2Vec2(weights.x * slope.x, weights.x * slope.y); 
			var r:b2Vec2 = new b2Vec2(weights.y * slope.x, weights.y * slope.y);
			var axis:b2Vec2 = slope.Copy();
			trackDef.lowerTranslation = weights.x;
			trackDef.upperTranslation = weights.y;
			
						
			axis.Normalize();
			
			var anchorDef:b2BodyDef = new b2BodyDef();
			anchorDef.position = center.Copy();
			anchorDef.type = b2Body.b2_staticBody;
			anchorBody = m_level.world.CreateBody(anchorDef);
			anchor = new Sprite();
			trackDef.enableLimit = true;
			trackDef.Initialize(anchorBody, m_physics, center, axis);
			joints.push(m_level.world.CreateJoint(trackDef));
			
			
			var trackGfx:Image = new Image(pipeTex);
			var w:Number = (weights.y - weights.x);
			var h:Number = .25;
			trackGfx.width = w;
			trackGfx.height = h;
			trackGfx.setTexCoords(3,new Point(w,h));
			trackGfx.setTexCoords(1,new Point(w,0));
			trackGfx.setTexCoords(2,new Point(0,h));
			trackGfx.setTexCoords(0, new Point(0, 0));
			trackGfx.x = weights.x;
			trackGfx.y = -h/2;
			anchor.addChild(trackGfx);
			anchor.rotation = Math.atan2(slope.y , slope.x);
			sprite.alpha=.5;
			
			
			const mkSize:Number=.4;
			var s:Quad=new Image(pipeTex);//new Quad(mkSize,mkSize);
			s.height=mkSize;
			s.width=mkSize;
			s.color=0xAAAAAA;
			s.x=-mkSize/2;
			s.y=-mkSize/2;
			s.alpha=10;
			addChild(s);
		}
		
		public function getBodyType():uint {
			return movement == FIXED ? b2Body.b2_staticBody 
				: b2Body.b2_dynamicBody;
		}

		public function getLevel():Level {
			return m_level;
		}	

		private function makeField():void {
			eField = new QuadBatch();

			var tmpCp:int = chargePolarity;
			chargePolarity = 1;
			var playerCharge:Charge = new Charge(m_level.getPlayer()
				.getCharges()[0].strength, new b2Vec2(0,0));

			var scaleFactX:Number = scale.x + chargeStrength 
				* playerCharge.strength * 4.5;
			var scaleFactY:Number = scale.y + chargeStrength
				* playerCharge.strength * 4.5;

			// resolution x resolution grid of quads
			var resolution:uint = Math.max(Math.min(8, (scaleFactX * ppm) / 45),3);
			var grid:uint = resolution + 1;
			var gridStep:Number = 1.0/resolution;
			var fVals:Vector.<uint> = new Vector.<uint>();

			for (var iy:uint = 0; iy < grid; ++iy) {
				for (var ix:uint = 0; ix < grid; ++ix) {
					// get charge strength at this point, as if it 
					// were appplied to player
					playerCharge.loc.x = ix*gridStep * scaleFactX
						- scaleFactX/2;
					playerCharge.loc.y = iy*gridStep * scaleFactY
						- scaleFactY/2;
					//[ix + iy*grid]
					fVals.push(Math.min(1.0,Math.abs(ChargableManager
						.getForceAt(this,playerCharge) / 800.0)) * 100);
				}
			}

			chargePolarity = tmpCp;

			// make ALL the quads
			for (iy = 0; iy < resolution; ++iy) {
				for (ix = 0; ix < resolution; ++ix) {
					var quad:Quad = new Quad(scaleFactX*gridStep,
						scaleFactY * gridStep);
					quad.x = ix * gridStep * scaleFactX;
					quad.y = iy * gridStep * scaleFactY;
					
					var shiftAmt:uint = chargePolarity == -1 ? 16 : 0;

					quad.setVertexColor(0,fVals[ix+iy*grid]<<shiftAmt);
					quad.setVertexColor(1,fVals[ix+iy*grid+1]<<shiftAmt);
					quad.setVertexColor(2,fVals[ix+(iy+1)*grid]<<shiftAmt);
					quad.setVertexColor(3,fVals[ix+(iy+1)*grid+1]<<shiftAmt);
					quad.blendMode = BlendMode.ADD;
					eField.addQuad(quad);
				}
			}

			eField.x = -scaleFactX/2;
			eField.y = -scaleFactY/2;
			eFieldScaleX = scaleFactX;
			eFieldScaleY = scaleFactY;
			eField.visible = chargePolarity != 0;
			if (movement == FIXED) {
				m_level.m_staticChargeLayer.addChild(eField);
			}
			else 
				m_level.m_dynamicChargeLayer.addChild(eField);
		}
	}
}
