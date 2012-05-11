package cgs.server.logging.messages
{
	import cgs.server.logging.GameServerData;
	
	import flash.system.Capabilities;

	public dynamic class PageloadMessage extends Message
	{
		private var _plDetails:Object;
		
		public function PageloadMessage(details:Object = null, serverData:GameServerData = null)
		{
			super(serverData);
			_plDetails = details;
			createDetails();
		}
		
		private function createDetails():void
		{
			if(_plDetails == null)
			{
				_plDetails = {};
			}
			
			//Add system parameters to page load message.
			_plDetails.os = Capabilities.os;
			_plDetails.resX = Capabilities.screenResolutionX;
			_plDetails.resY = Capabilities.screenResolutionY;
			_plDetails.dpi = Capabilities.screenDPI;
			_plDetails.flash = Capabilities.version;
			_plDetails.cpu = Capabilities.cpuArchitecture;
			_plDetails.pixelAspect = Capabilities.pixelAspectRatio;
			_plDetails.language = Capabilities.language;
			
			//Add the domain if it has been set.
			var domain:String = GameServerData.swfDomain;
			if(domain != null)
			{
				_plDetails.domain = domain;
			}
			
			addProperty("pl_detail", _plDetails);
		}
	}
}