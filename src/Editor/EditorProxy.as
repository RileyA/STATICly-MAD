package Editor {
	import flash.display.Sprite;
	public interface EditorProxy {
		function loseFocus():void;
		function gainFocus():void;
		function populateForm(form:Sprite):void;
		function updateForm():void;
		function getCaption():String;
	}
}
