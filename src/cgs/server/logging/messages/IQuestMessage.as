package cgs.server.logging.messages
{
    public interface IQuestMessage
    {
		function setQuestID(value:int):void;
		
		/**
		 * Sets the dynamic quest id for the quest message.
		 */
        function setDQID(value:String):void;
		
		function get dqid():String;
		
		function injectParams():void;
		
		function get messageObject():Object;
		
		function getQuestID():int;
		
		function addProperty(key:String, value:*):void;
    }
}