package edu.amrita.aview.core.login.boilerplate.events
{
	import flash.events.Event;
	
	public class LoginStatusEvent extends Event
	{
		public static const LOGIN_SUCCESS:String="loginSuccess";
		public static const LOGIN_FAILED:String="loginFailed";
		public static var SECURE_SERVER : String = "secureServer";
		public static var INVALID_SERVER : String = "invalidServer";
		public static var SERVER_CREATION_COMPLETE : String = "ServerCreation";
		public static var APPLICATION_CLOSE : String = "applicationClose";
		public static var SERVER_ERROR : String = "serverError";
		
		public function LoginStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
