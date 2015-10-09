////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: ClassServerChangeConsumer.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 *
 * This helper class is used to call the remote java methods
 * 
 */
package edu.amrita.aview.core.gclm.helper
{
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.SessionEntry;
	import edu.amrita.aview.core.gclm.vo.ClassServerVO;
	import edu.amrita.aview.core.gclm.vo.ClassVO;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.messaging.ChannelSet;
	import mx.messaging.Consumer;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.events.MessageEvent;
	import mx.messaging.events.MessageFaultEvent;
	
	public class ClassServerChangeConsumer
	{
		/**
		 * For Log API
		 */
		private var logger:ILogger=Log.getLogger("aview.edu.amrita.aview.core.gclm.helper.ClassServerChangeConsumer");
		
		private var classServerConsumer:Consumer=null;
		
		/**
		 * @public
		 * Function :
		 *
		 */
		public function ClassServerChangeConsumer()
		{
			classServerConsumer=new Consumer();
			classServerConsumer.destination="classServerChange";
			var cs:ChannelSet=new ChannelSet();
			cs.addChannel(new AMFChannel("my-polling-amf", ClassroomContext.WEBAPP_AVIEW_POLLING_END_POINT));
			classServerConsumer.channelSet=cs;
			
			classServerConsumer.addEventListener(MessageEvent.MESSAGE, messageHandler);
			classServerConsumer.addEventListener(MessageFaultEvent.FAULT, faultHandler);
			
			classServerConsumer.selector="classId = " + ClassroomContext.aviewClass.classId;
			
			//Reconnection properties
			classServerConsumer.resubscribeAttempts=30;
			classServerConsumer.resubscribeInterval=10 * 1000;
		}
		
		/**
		 * @public
		 * Function :
		 *
		 * @return void
		 */
		public function subscribeConsumer():void
		{
			classServerConsumer.subscribe();
		}
		
		
		/**
		 * @public
		 * Function :
		 *
		 * @return void
		 */
		public function unSubscribeConsumer():void
		{
			classServerConsumer.unsubscribe();
		}
		
		/**
		 * @private
		 * Function :Write received message to TextArea control.
		 * @param event
		 * @return void
		 */
		private function messageHandler(event:MessageEvent):void
		{
			if (ClassroomContext.aviewClass.classId != Number(event.message.body.classId))
				return;
			ClassroomContext.aviewClassServerFailover=event.message.body as ClassVO;
			var isIpDiff:Boolean=false;
			var serversData:ArrayCollection=new ArrayCollection();
			trace("************" + ClassroomContext.CONTENT_DOCUMENT);
			trace("************" + ClassroomContext.FMS_USER);
			trace("************" + ClassroomContext.DESKTOP_SHARING_SERVER);
			for (var counter:int=0; counter < ClassroomContext.aviewClassServerFailover.classServers.length; counter++)
			{
				var classServer:ClassServerVO=ClassServerVO(ClassroomContext.aviewClassServerFailover.classServers.getItemAt(counter));
				trace("************" + classServer.serverTypeName + ":" + classServer.server.serverIp);
				if (classServer.serverTypeName == Constants.CONTENT_SERVER)
				{
					if (ClassroomContext.CONTENT_DOCUMENT != classServer.server.serverIp)
					{
						isIpDiff=true;
						break;
					}
				}
				else if (classServer.serverTypeName == Constants.FMS_DATA)
				{
					if (ClassroomContext.FMS_USER != classServer.server.serverIp)
					{
						isIpDiff=true;
						break;
					}
				}
				else if (classServer.serverTypeName == Constants.FMS_DESKTOP_SHARING)
				{
					if (ClassroomContext.DESKTOP_SHARING_SERVER != classServer.server.serverIp)
					{
						isIpDiff=true;
						break;
					}
				}
				else if (classServer.serverTypeName == Constants.FMS_PRESENTER || classServer.serverTypeName == Constants.FMS_VIEWER)
				{
					var tempObject:Object=new Object();
					tempObject.ip=classServer.server.serverIp;
					tempObject.serverCategory=classServer.server.serverCategory;
					tempObject.serverType=classServer.serverTypeName;
					tempObject.portNumber=classServer.serverPort;
					tempObject.bandWidth=classServer.presenterPublishingBandwidthKbps;
					serversData.addItem(tempObject);
				}
			}
			var sort:Sort=new Sort();
			sort.fields=[new SortField("serverType", true), new SortField("bandWidth", true, false, true)];
			serversData.sort=sort;
			serversData.refresh();
			if (!isIpDiff)
			{
				if (serversData.length != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData.length)
				{
					isIpDiff=true;
				}
				else
				{
					for (var i:int=0; i < serversData.length; i++)
					{
						trace("************** " + serversData[i].ip + " " + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].ip);
						if (serversData[i].ip != FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.videoServersData[i].ip)
						{
							isIpDiff=true;
							break;
						}
					}
				}
			}
			if (!isIpDiff)
			{
				return;
			}
			ClassroomContext.aviewClass=event.message.body as ClassVO;
			logger.info("New Servers are received from Admin:" + ClassroomContext.aviewClass);
			if(ClassroomContext.aviewClass.classType == "Meeting")
			{
				new SessionEntry().populateClassRoomServers(true);
			}
			else
			{
				trace("***** Main app: " + FlexGlobals.topLevelApplication.mainApp);
				trace("***** Main app: " + FlexGlobals.topLevelApplication.mainApp.mainContainerComp);
				trace("***** Main app: " + FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can);
				if(FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.sessionEntry != null)
				{
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lectureNotice_Can.sessionEntry.populateClassRoomServers(true);
				}
			}
			
		}
		
		/**
		 * @private
		 * Function : fault handler for
		 * @param event
		 * @return void
		 */
		private function faultHandler(event:MessageFaultEvent):void
		{
			var faultMessage:String=event.faultCode + ":" + event.faultDetail + ":" + event.faultString;
			if (event.rootCause)
			{
				faultMessage+=":Root Cause:" + event.rootCause.toString();
			}
			logger.error("Error while Consuming ClassServer Change Message:" + faultMessage);
		}
		
	}
}
