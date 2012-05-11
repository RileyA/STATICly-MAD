package cgs.server.logging.actions
{
	public interface IClientAction
	{
		//Get the object which will be serialized into JSON and sent to server.
		function get actionObject():Object;
	}
}