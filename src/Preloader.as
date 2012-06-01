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
    	
        public function Preloader()
        {
        	progressText=new TextField();
        	progressText.textColor=0xFF0000;
			progressText.width=800;
			progressText.height=600;
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
			if (verInt<11) {
				errorText+="UPGRADE YOUR FLASH PLAYER\nRequires: Flash Player 11\nRunning: Flash Player "+verNumString;
			}
			
			
			progressText.text=loadText+"1"+errorText;
			addChild(progressText);
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
                trace(percent);
                
				progressText.text=loadText+(int)(percent)+errorText;
				
				
            }
        }
        
        private function init():void
        {
            //if class is inside package you'll have use full path ex.org.actionscript.Main
            var mainClass:Class = Class(getDefinitionByName("Main")); 
            if(mainClass)
            {
            	var i:int;
            	for (i=0;i<1000000;i++){
            		trace("x"+i);
            	}
                
                var main:Object = new mainClass(stage);
                addChild(main as DisplayObject);
                stage.removeChild(this);
            }
        }
    }
}