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
			removeEventListener(Event.ADDED_TO_STAGE, 
				super.onAdded);
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		override protected function onAdded(e:Event):void {
			LoggerUtils.initLogger();
			addState(new Editor.EditorState(this));
			update();
		}
	}
}
