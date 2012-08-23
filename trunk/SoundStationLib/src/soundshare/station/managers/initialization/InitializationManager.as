package soundshare.station.managers.initialization
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import flashsocket.json.JSONFacade;
	
	import soundshare.station.managers.initialization.events.InitializationManagerEvent;
	
	public class InitializationManager extends EventDispatcher
	{
		public function InitializationManager()
		{
			super();
		}
		
		public function init(url:String):void
		{
			trace("-init-", url + "/init");
			
			var urlRequest:URLRequest = new URLRequest(url + "/init");
			urlRequest.method = URLRequestMethod.GET;
			
			var urlLoader:URLLoader = addListeners(
				new URLLoader(),
				onInitComplete,
				onInitPregress,
				onInitSecurityError,
				onInitIOError
			);
			
			urlLoader.load(urlRequest);
		}
		
		protected function onInitComplete(e:Event):void 
		{
			var result:Object = JSONFacade.parse((e.currentTarget as URLLoader).data);
			
			if (!result.error)
			{
				var event:InitializationManagerEvent = new InitializationManagerEvent(InitializationManagerEvent.COMPLETE);
				event.data = result;
				
				trace("-onInitComplete-", result.data);
				
				dispatchEvent(event);
			}
			else
				dispatchEvent(new InitializationManagerEvent(InitializationManagerEvent.ERROR));
			
			removeListeners(e.currentTarget, onInitComplete, onInitPregress, onInitSecurityError, onInitIOError);
		}
		
		protected function onInitPregress(e:ProgressEvent):void 
		{
			trace("-onInitPregress-");
		}
		
		protected function onInitSecurityError(e:SecurityErrorEvent):void 
		{
			trace("-onInitSecurityError-");
			
			removeListeners(e.currentTarget, onInitComplete, onInitPregress, onInitSecurityError, onInitIOError);
			dispatchEvent(new InitializationManagerEvent(InitializationManagerEvent.ERROR));
		}
		
		protected function onInitIOError(e:IOErrorEvent):void 
		{
			trace("-onInitIOError-");
			
			removeListeners(e.currentTarget, onInitComplete, onInitPregress, onInitSecurityError, onInitIOError);
			dispatchEvent(new InitializationManagerEvent(InitializationManagerEvent.ERROR));
		}
		
		// ******************************************************************************************************
		// 												
		// ******************************************************************************************************
		
		protected function addListeners(target:Object, complete:Function, progress:Function, securityError:Function, IOError:Function):URLLoader
		{
			target.addEventListener(Event.COMPLETE, complete);
			target.addEventListener(ProgressEvent.PROGRESS, progress);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			target.addEventListener(IOErrorEvent.IO_ERROR, IOError);
			
			return target as URLLoader;
		}
		
		protected function removeListeners(target:Object, complete:Function, progress:Function, securityError:Function, IOError:Function):void
		{
			target.removeEventListener(Event.COMPLETE, complete);
			target.removeEventListener(ProgressEvent.PROGRESS, progress);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			target.removeEventListener(IOErrorEvent.IO_ERROR, IOError);
		}
	}
}

