// http://www.actionscript.org/forums/showthread.php3?p=1076780#post1076780
package
{
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;
    
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import flash.system.Capabilities;
    
    public class Preloader extends MovieClip
    {
    	
    	private var progressText:TextField;
    	
    	private const loadText:String="STATICly MAD\nLoading: ";
    	private var errorText:String;
    	
    	private var die:Boolean;
    	private const myDomains:Array=["craigm.wdfiles.com",".ungrounded.net",".newgrounds.com"];
    	private const suggestDomain:String="http://www.craigm.info/staticly-mad";
    	private const lock:Boolean=true;
    	
        public function Preloader()
        {
        	progressText=new TextField();
        	progressText.textColor=0xFF0000;
			progressText.width=800;
			progressText.height=400;
			progressText.x=0;
			progressText.y=0;
			
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 40;
			
			progressText.defaultTextFormat = myFormat;
			
			var ver:String=Capabilities.version;
			var split:int = ver.search(",");
			var verNumString:String = ver.slice(4, split);
			var verInt:int=(int)(verNumString);
			errorText = "%\n"
			die=!checkDomain();
			if (die){
				errorText+="** URL not authorized **\n";
				errorText+="("+this.loaderInfo.url+")\n"
				errorText+="Play on "+suggestDomain+"\n";
			}
			
			if (verInt<11) {
				errorText+="UPGRADE YOUR FLASH PLAYER\nRequires: Flash Player 11\nRunning: Flash Player "+verNumString;
			}
			
			
			
			progressText.text=loadText+"1"+errorText;
			addChild(progressText);
			stage.addChild(this);
			
			
			myFormat = new TextFormat();
			myFormat.size = 28;
			
			
			var creditText:TextField=new TextField();
			creditText.defaultTextFormat = myFormat;
			creditText.textColor=0xFF6666;
			creditText.width=800;
			creditText.height=200;
			creditText.x=0;
			creditText.y=400;
			creditText.text="By:\nCraig Macomber, Riley Adams,\nMatt Hall and David Mailhot";
			addChild(creditText);
			stage.addChild(this);
			
			
			
			
            stop();
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        public function onEnterFrame(event:Event):void
        {
            if(framesLoaded == totalFrames)
            {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                nextFrame();
                init();
            }
            else
            {
                var percent:Number = (stage.loaderInfo.bytesLoaded / stage.loaderInfo.bytesTotal) * 100;
                //trace(percent);
                
				progressText.text=loadText+(int)(percent)+errorText;
				
				
            }
        }
        
        private function init():void
        {
           if (lock&&die) return;
           
           //if class is inside package you'll have use full path ex.org.actionscript.Main
            var mainClass:Class = Class(getDefinitionByName("Main")); 
            if(mainClass){
                var main:Object = new mainClass(stage);
                addChild(main as DisplayObject);
                stage.removeChild(this);
            }
        }
        
        // http://www.actionscript.org/forums/showthread.php3?t=50214
		private function checkDomain():Boolean{
			var current:String=this.loaderInfo.url;
			var parts:Array=current.split("/",4);
			var i:int;
			for (i=0;i<myDomains.length;i++){
				var myDomain:String=myDomains[i];
				if (parts.length==4 && parts[2].length>=myDomain.length &&parts[2].substr(-myDomain.length)==myDomain) {
					return true;
				}
			}
			return false;
		}
        
    }    
}