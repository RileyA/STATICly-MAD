package cgs.server.logging.actions
{
	public interface IActionBufferHandler
	{
		function setProperties(startFlushTime:Number, endFlushTime:Number, rampTime:Number):void;
		
		/**
		 * Set a listener on the handler which can be called to flush actions to the server.
		 */
		function set listener(value:IActionBufferListener):void;
		
		/**
		 * Start the handler with flushing action messages to the server.
		 */
		function start():void;
		
		/**
		 * Stop the handler from flushing any messages.
		 */
		function stop():void;
		
		/**
		 * Reset the handler to its default starting values.
		 */
		function reset():void;
		
		/**
		 * External time handler.
		 */
		function onTick(delta:Number):void;
	}
}