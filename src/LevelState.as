package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Player;
	import Chargable.*;

	/** A basic level gameplay state */
	public class LevelState extends GameState {

		private var m_level:Level;

		public function LevelState(game:Game):void {
			super(game);
		}

		override public function init():void {
			m_level = new Level(this);
		}
		
		override public function deinit():void {
			m_level = null;
		}

		override public function update(delta:Number):Boolean {
			var isDone:Boolean = false;
			isDone ||= !m_level.update(delta);
			isDone ||= Keys.isKeyPressed(Keyboard.ESCAPE);
			return !isDone;
		}

	}
}
