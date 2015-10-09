package edu.amrita.aview.core.common
{
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.shared.audit.AuditContext;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.core.Window;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	applicationType::desktop{
		import spark.components.WindowedApplication;
	}
	
	import ws.tink.mx.events.AlertEvent;

	public class FMSPortTester
	{
		private var fmsIP:String = null;
		private var fmsModule:String = null;
		private var connectionSuccessFunction:Function = null;
		private var ncSelectFMSProtocol:NetConnection = null;
		private var connectionMsgAlert:Alert = null;
		private var callingComp:UIComponent = null;
		private var closeOnFailure:Boolean = false;

		public function FMSPortTester(fmsIP:String,fmsModule:String,connectionSuccessFunction:Function,callingComp:UIComponent,closeOnFailure:Boolean = false)
		{
			this.fmsIP = fmsIP;
			this.fmsModule = fmsModule;
			this.connectionSuccessFunction = connectionSuccessFunction;
			this.callingComp = callingComp;
			this.closeOnFailure = closeOnFailure;
		}
		
		private var fmsURL:String = "";
		
		public function selectFMSPort():void
		{
			if(ncSelectFMSProtocol)
			{
				ncSelectFMSProtocol=null;
			}
			ncSelectFMSProtocol=new NetConnection();
			ncSelectFMSProtocol.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorEventHandler);
			ncSelectFMSProtocol.addEventListener(NetStatusEvent.NET_STATUS,checkFMSPortConnect);
			
			//Create this only once. This method might be called multiple times.
			if(!connectionMsgAlert)
			{
				connectionMsgAlert = Alert.show("Checking your connections to the server.\n Please wait...","Connection",null,this.callingComp);
				connectionMsgAlert.mx_internal::alertForm.mx_internal::defaultButton.visible = false;
				//.mx_internal::alertForm.mx_internal::defaultButton.visible = false;
			}
			
			fmsURL = this.fmsIP+":"+ClassroomContext.portFMS;
			ncSelectFMSProtocol.connect(
				ClassroomContext.protocolFMS+"://"+fmsURL+this.fmsModule,
				ClassroomContext.userVO.userName);
		}
		private function checkFMSPortConnect(event:NetStatusEvent):void
		{
			switch( event.info.code ) 
			{
				case "NetConnection.Connect.Success":	
					AuditContext.userAction.connectionSuccessEventLog("ConnectionTester",fmsURL,null);
					ncSelectFMSProtocol.call("disconnectConnection",null);
					ncSelectFMSProtocol.close();
					ncSelectFMSProtocol=null;
					PopUpManager.removePopUp(connectionMsgAlert);
					this.connectionSuccessFunction();
					trace("Fms connection test is successful:Protocol:"+ClassroomContext.protocolFMS
						+":port:"+ClassroomContext.portFMS);
					break;
				case "NetConnection.Connect.Failed":
					AuditContext.userAction.connectionFailEventLog("ConnectionTester",fmsURL);
					if(ClassroomContext.portFMS!=Constants.FMS_SERVER_PORT_FIREWALL)
					{
						ClassroomContext.portFMS=Constants.FMS_SERVER_PORT_FIREWALL;
						selectFMSPort();
					}
					else
					{
						Alert.show("Port 80 or 1935 needs to be open for RTMP streaming. Contact your System Administrator.\n Class entry is not allowed","Class entry is not allowed",
							Alert.OK,this.callingComp,closeComp);
						trace("Unable to connect on all the FMS connection parameters");
						PopUpManager.removePopUp(connectionMsgAlert);
					}
					break;
				case "NetConnection.Connect.Rejected":
					AuditContext.userAction.connectionRejectEventLog("ConnectionTester",fmsURL);
					Alert.show("Connection Rejected. Contact your System Administrator.\n Class entry is not allowed","Class entry is not allowed",
						Alert.OK,this.callingComp,closeComp);
					trace("NetConnection.Connect.Rejected");
					PopUpManager.removePopUp(connectionMsgAlert);
			}
		}
		
		private function closeComp(event:CloseEvent):void
		{
			if(this.closeOnFailure)
			{
				applicationType::desktop{
					if(this.callingComp is Window)
					{
						((this.callingComp) as Window).close();
					}
					else if(this.callingComp is WindowedApplication)
					{
						((this.callingComp) as WindowedApplication).close();
					}
				}
			}
			
		}
		private function asyncErrorEventHandler(event:Event):void
		{
		}
	}
}
