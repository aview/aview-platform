////////////////////////////////////////////////////////////////////////////////
//
// Copyright  Â© 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *
 * File			: AuditLecture.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 *
 * Helps in populating the AuditLectureVO object with the lecture audit information
 * and interfaces with database helper for storing in database.
 *
 */

package edu.amrita.aview.audit
{
	import edu.amrita.aview.audit.helper.AuditLectureHelper;
	import edu.amrita.aview.audit.AuditContext;
	import edu.amrita.aview.audit.vo.AuditLectureServerVO;
	import edu.amrita.aview.audit.vo.AuditLectureVO;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	
	/**
	 * Helps in populating the AuditLectureVO object with the lecture audit information
	 * and interfaces with database helper for storing in database.
	 */
	public class AuditLecture
	{
		/**
		 * Helper class for database operations. Connects with Java backend
		 */
		private var auditLectureHelper:AuditLectureHelper=new AuditLectureHelper();
		/**
		 * Logger class for client side file and console logging
		 */
		private var auditLog:ILogger=Log.getLogger("edu.amrita.aview.audit.AuditLecture");
		
		/**
		 *
		 * @public
		 * Creates the AuditLectureVO objects based on the lecture details and
		 * calls the auditLectureHelper for storing in the database
		 *
		 * @return void
		 *
		 ***/
		public function auditLectureEntry():void
		{
			
			var auditLectureVO:AuditLectureVO=null;
			auditLectureVO=new AuditLectureVO();
			
			//Populating the login audit reference
			auditLectureVO.auditUserLoginid=AuditContext.userLoginVO.auditUserLoginId;
			
			//Populating the configs of the lecture/class, the user is about to enter into
			auditLectureVO.lectureId=ClassroomContext.lecture.lectureId;
			auditLectureVO.isMultiBitrate=ClassroomContext.aviewClass.isMultiBitrate;
			auditLectureVO.maxStudents=ClassroomContext.aviewClass.maxStudents;
			auditLectureVO.minPublishingBandwidthKbps=ClassroomContext.aviewClass.minPublishingBandwidthKbps;
			auditLectureVO.maxPublishingBandwidthKbps=ClassroomContext.aviewClass.maxPublishingBandwidthKbps;
			auditLectureVO.isModerator=(ClassroomContext.isModerator) ? "Y" : "N";
			auditLectureVO.videoCodec=ClassroomContext.aviewClass.videoCodec;
			
			//Incase if the current user is the moderator for the class, then we also store the class server settings against the moderator
			//We do not want to store this data for all users of the class, because it will be just a repetition,
			if (ClassroomContext.isModerator)
			{
				for (var counter:int=0; counter < ClassroomContext.aviewClass.classServers.length; counter++)
				{
					var auditLectureServer:AuditLectureServerVO=new AuditLectureServerVO();
					auditLectureServer.serverName=ClassroomContext.aviewClass.classServers[counter].server.serverName;
					auditLectureServer.serverIP=ClassroomContext.aviewClass.classServers[counter].server.serverIp;
					auditLectureServer.serverDomain=ClassroomContext.aviewClass.classServers[counter].server.serverDomain;
					auditLectureServer.serverPort=ClassroomContext.aviewClass.classServers[counter].serverPort;
					auditLectureServer.presenterPublishingBandwidthKbps=ClassroomContext.aviewClass.classServers[counter].presenterPublishingBwsKbps;
					auditLectureServer.serverTypeId=ClassroomContext.aviewClass.classServers[counter].serverTypeId;
					auditLectureVO.addAuditLectureServer(auditLectureServer);
						//auditLectureServer.aviewAuditLecture = auditLectureVO;
				}
			}
			
			auditLecture(auditLectureVO);
		}
		
		/**
		 *
		 * @public
		 * Calls the AuditLectureHelper and stores the VO
		 *
		 * @param auditLectureVO - Fully populated AuditLectureVO
		 * @return void
		 *
		 ***/
		private function auditLecture(auditLectureVO:AuditLectureVO):void
		{
			auditLectureHelper.createAuditLecture(auditLectureVO,createAuditLectureResultHandler);
		}
		
		/**
		 *
		 * @public
		 * Result handler of the createAuditLecture.
		 *
		 * @param auditLectureVO - The created AuditLectureVO, returned from the server, now has the database Id also populated
		 * @return void
		 *
		 ***/
		public function createAuditLectureResultHandler(auditLectureVO:AuditLectureVO):void
		{
			//Alert.show("auditLecture :"+event.toString());
			if (Log.isInfo()) auditLog.info("created auditLecture :{0}", auditLectureVO.toString());
			AuditContext.auditLectureVO=auditLectureVO;
		}
		/**
		 *
		 * @public
		 * Calls the AuditLectureHelper for updating the earlier auditLectureVO, with the modified date as the Lecture Exit time.
		 * This method is called during lecture exit.
		 * The modified date is populated by the server upon receiving this call.
		 *
		 * @return void
		 *
		 ***/
		public function auditLectureExit():void
		{
			if (AuditContext.auditLectureVO != null)
			{
				auditLectureHelper.updateAuditLectureById(AuditContext.auditLectureVO.auditLectureId,updateAuditLectureByIdResultHandler);
			}
		}
		
		/**
		 *
		 * @public
		 * Result handler of the updateAuditLectureById.
		 *
		 * @param auditLectureVO - The updated AuditLectureVO returned from the server
		 * @return void
		 *
		 ***/
		public function updateAuditLectureByIdResultHandler(auditLectureVO:AuditLectureVO):void
		{
			//Alert.show("auditLecture :"+event.toString());
			if (Log.isInfo()) auditLog.info("Updated auditLecture :{0}", auditLectureVO.toString());
			AuditContext.auditLectureVO=auditLectureVO;
		}
	}
}
