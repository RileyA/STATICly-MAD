package cgs.server.logging
{
	import cgs.server.logging.requests.IServerRequest;

	public interface IServerRequestHandler
	{
		function request(serverRequest:IServerRequest):void;
	}
}