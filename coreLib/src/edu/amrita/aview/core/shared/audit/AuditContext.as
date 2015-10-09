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
 * File			: AuditContext.as
 * Module		: Audit
 * Developer(s)	: Ramesh G, Sethu, Ashish
 * Reviewer(s)	: Meena S
 *
 * This class holds all the state information regarding Auditing
 * This has all the classes which communicate the audit information to server
 *
 * This class prepares the auditing service during the initialization process for the modules to use
 *
 * This class also holds relvant auditing context information such as UserLoginVO, AuditLectureVO & AuditUserSettingVO
 * so that actions logged in the right context.
 *
 * This will be accessed by entire AVC code
 */

package edu.amrita.aview.core.shared.audit
{
	import edu.amrita.aview.core.shared.audit.vo.ActionVO;
	import edu.amrita.aview.core.shared.audit.vo.AuditLectureVO;
	import edu.amrita.aview.core.gclm.vo.UserLoginVO;
	
	import mx.collections.ArrayCollection;
	
	
	/**
	 *
	 * This class holds all the state information regarding Auditing
	 * This has all the classes which communicate the audit information to server
	 *
	 * This class prepares the auditing service during the initialization process for the modules to use
	 *
	 * This class also holds relvant auditing context information such as UserLoginVO, AuditLectureVO & AuditUserSettingVO
	 * so that actions logged in the right context.
	 *
	 * This will be accessed by entire AVC code
	 */
	public class AuditContext
	{
		/**
		 * Holds the user Login audit information.
		 * Will be used as a reference to further auditing.
		 * Populated during the login process.
		 */
		public static var userLoginVO:UserLoginVO=null;
		
		/**
		 * Action name->ActionVO map. Used by various modules to get hold of the ActionID for a given Action
		 */
		public static var actionsHash:Object=null;
		
		/**
		 * Holds the Lecture entry/exit auditing information.
		 * Will be used as a reference to further auditing.
		 * Populated during the lecture entry and updated during lecture exit.
		 */
		public static var auditLectureVO:AuditLectureVO=null;
		
		
		/**
		 * Helps in auditing the user Login
		 */
		public static var login:AuditUserLogin=null;
		
		/**
		 * Helps in populating the ActionVOs
		 */
		public static var action:Action=null;
		
		/**
		 * Helps in auditing the lecture entry/exit
		 */
		public static var lecture:AuditLecture=null;
		
		/**
		 * Helps in auditing the actions of all the modules
		 */
		public static var userAction:AuditUserAction=null;
		
		/**
		 *
		 * @public
		 * Initializes all the Auditing helper classes, which interface with
		 * database helper classes for storing the auditing information in database
		 * Also fetches the ActionVOs from database and populates them in actionsHash
		 *
		 * @return void
		 *
		 ***/
		public static function init():void
		{
			login=new AuditUserLogin();
			
			action=new Action();
			action.getActions();
			
			lecture=new AuditLecture();
			userAction=new AuditUserAction();
		}
		/**
		 *
		 * @public
		 * Invoked during the lecture exit. It clears out the lecture auditing information.
		 * Lecture auditing information is re populated during the next lecture entry.
		 *
		 * @return void
		 *
		 ***/
		public static function resetLectureAudit():void
		{
			auditLectureVO=null;
		}
		
		/**
		 *
		 * @public
		 * Populates the actionsHash from the list of ActionVOs.
		 * So that the actions can be accessed by actionName easily for rest of the modules
		 *
		 * @param ActionVOs coming in from result handler of actionHelper.getActions
		 * @return void
		 *
		 ***/
		public static function populateActionIds(actionsAC:ArrayCollection):void
		{
			actionsHash=new Object();
			for (var i:int=0; i < actionsAC.length; i++)
			{
				var actionVO:ActionVO=actionsAC.getItemAt(i) as ActionVO;
				actionsHash[actionVO.actionName]=actionVO.actionId;
			}
		}
	}
}
