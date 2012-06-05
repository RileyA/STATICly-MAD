package  
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	public class Kong {
		
		public static var kongregate:*;
		
		public static function init(stage:DisplayObject):void {
			// Pull the API path from the FlashVars
			var paramObj:Object = LoaderInfo(stage.loaderInfo).parameters;

			// The API path. The "shadow" API will load if testing locally. 
			var apiPath:String = paramObj.kongregate_api_path || 
			  "http://www.kongregate.com/flash/API_AS3_Local.swf";

			// Allow the API access to this SWF
			Security.allowDomain(apiPath);

			// Load the API
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			//this.addChild(loader);
		}
		
		// This function is called when loading is complete
		private static function loadComplete(event:Event):void {
			// Save Kongregate API reference
			kongregate = event.target.content;
			
			// Connect to the back-end
			if(kongregate.services != null)
				kongregate.services.connect();
			
			submit("init", 1);
			// You can now access the API via:
			// kongregate.services
			// kongregate.user
			// kongregate.scores
			// kongregate.stats
			// etc...
		}
		
		public static function submit(name:String, amount:int):void {
			if(Config.stats && kongregate.stats != null)
				kongregate.stats.submit(name, amount);
		}
		
	}

}