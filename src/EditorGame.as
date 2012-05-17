package {

	import starling.display.Sprite;
	import starling.events.Event;
	import flash.utils.getTimer;
	import cse481d.Logger;
	import OverworldState;
	import flash.utils.Dictionary;
	import Config;
	import Editor.EditorState;

	public class EditorGame extends Game  {
		public function EditorGame():void {
		}

		override protected function onAdded(e:Event):void {
			LoggerUtils.initLogger();
			addState(new Editor.EditorState(this));
			update();
		}
	}
}
