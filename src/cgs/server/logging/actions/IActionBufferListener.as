package cgs.server.logging.actions
{
	public interface IActionBufferListener
	{
		function flushActions(localDQID:int = -1, callback:Function = null):void;
	}
}