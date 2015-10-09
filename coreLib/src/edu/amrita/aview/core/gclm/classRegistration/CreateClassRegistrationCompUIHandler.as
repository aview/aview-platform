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
 * File			: CreateClassRegistrationCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 *
 * This Action Script handler for CreateClassRegistrationComp.mxml
 * Based on the logged in user credentials this component behaves as follows:
 * Master Admin: Can add class registration for any user for any class
 * Institute Administrators: Can create class registrations for any users within their insitute for any class
 * Others: Can create class registration for any class only for themselves. This class registration will
 * be approval pending status. The master admin/admin or moderators has to approve the registration
 */
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.ClassRegistrationHelper;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.vo.ClassRegisterVO;
import edu.amrita.aview.core.gclm.vo.ClassVO;
import edu.amrita.aview.core.gclm.vo.UserVO;
import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.util.ArrayCollectionUtil;
import edu.amrita.aview.core.shared.vo.StatusVO;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

/**
 * To store all the active aview classes 
 */
[Bindable]
public var classesAC:ArrayCollection=new ArrayCollection();
/**
 * To keep track if the cancel button has been clicked 
 */
public var hasClickedCancelButton:Boolean;
/**
 * To keep track if any user registration has happened 
 */
public var isUserRegistration:Boolean=false;
/**
 * To store all the class registration statuses 
 */
[Bindable]
private var classRegistrationStatusesAC:ArrayCollection=new ArrayCollection();
/**
 * To store the class registration object for update 
 */
private var classRegistration:ClassRegisterVO=null;
/**
 * To store the error message during validation 
 */ 
private var errorMessage:String="";
/**
 * To store the status id 
 */
private var statusId:Number=0;
/**
 * The helper class to communicate with the server 
 */
private var classRegistraionHelper:ClassRegistrationHelper=null;
private var userHelper:UserHelper=null;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.classRegistration.CreateClassRegistrationCompUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the CreateClassRegistrationComp
 * This function is called from ClassRegistrationComp.mxml
 * @param classReg type of ClassRegisterVO
 * @return void
 *
 */
public function init(classReg:ClassRegisterVO=null):void
{
	userHelper=new UserHelper();
	classRegistraionHelper=new ClassRegistrationHelper();
	hasClickedCancelButton=true;
	setStatusesDataProvider();
	
	//Can't edit the unique key combinations (user & class)
	if (classReg != null)
	{
		this.classRegistration=ObjectUtil.copy(classReg) as ClassRegisterVO;
		populateClassRegisterData();
		
		txtInpUserName.visible=false;
		btnValidate.visible=false;
		lblUserName.visible=true;
		lblUserName.text=this.classRegistration.user.userName;
		
		cmbClasses.visible=false;
		lblClassName.visible=true;
		lblClassName.text=this.classRegistration.aviewClass.className;
		//Hide the user status details incase of teacher/student user role
		// Fix for Bug #19727 start 
		if ((ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
		{
			hideUserStatus();
		}
		// Fix for Bug #19727 end
	}
	//For new class registration
	else
	{
		this.classRegistration=new ClassRegisterVO();
		rbPersonalComputer.selected=true;
		rbClassroom.selected=false;
		// Fix for Bug #19727 start 
		if ((ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
		// Fix for Bug #19727 end 	
		{
			txtInpUserName.text=ClassroomContext.userVO.userName;
			userHelper.getUserByUserName(ClassroomContext.userVO.userName,getUserByUserNameResultHandler);
			txtInpUserName.enabled=false;
			//Fix for Bug # 3238 start
			classRegistration.user=new UserVO();
			classRegistration.user.userId=ClassroomContext.userVO.userId;
				//Fix for Bug # 3238 end
		}
		else
		{
			setRBModerator(ClassroomContext.userVO.role);
		}
		resetSmartCombos();
		// Fix for Bug #19727 start 
		if ((ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
		// Fix for Bug #19727 end 			
		{
			setUserStatus(StatusVO.PENDING_STATUS);
			hideUserStatus();
		}
	}
	
	if (isUserRegistration)
	{
		var ev:MouseEvent;
		chkModulesAll.selected=true;
		modulesAllClickHandler(ev);
	}
}

/**
 *
 * @public
 * This function is the result handler for getting users by UserName
 * This function is made public because the UserHelper.as will call this once it
 * gets the result from the server
 * @param userVO type of UserVO
 * @return void
 *
 */
public function getUserByUserNameResultHandler(userVO:UserVO):void
{
	//Check if the result is a valid user vo object. throw error otherwise
	if (userVO != null)
	{
		classRegistration.user=userVO;
		setUserDetailsLabel(userVO.fname, userVO.lname, userVO.role, userVO.instituteName);
		setRBModerator(userVO.role);
		btnSaveClassReg.enabled=true;
	}
	else
	{
		lblErrorUser.text="* User not found. Please enter a valid User Name";
		btnValidate.enabled=true;
	}
}

/**
 *
 * @public
 * This function is the result handler for creating a new class registration
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of ResultEvent
 * @return void
 *
 */
public function createClassRegistrationResultHandler(event:ResultEvent):void
{
	hasClickedCancelButton=false;
	CustomAlert.info("Class registration created successfully");
	closeCreateClassRegistrationComp();
}

/**
 *
 * @public
 * This function is the fault handler for creating a new class registration
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of FaultEvent
 * @return void
 *
 */
public function createClassRegistrationFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::classRegistration::CreateClassRegistrationCompUIHandler::createClassRegistrationFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	hasClickedCancelButton=false;
	var strMsg:String=event.fault.faultString;
	//Error could be because of duplicate entry.
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		//Fix for Bug # 19688
		CustomAlert.error("User is already registered for the class");
	} // General bug report if it is not duplicate constraint violation
	//Error because trying to assign more than one moderator for a class
	else if (strMsg.indexOf("Cannot assign more than one moderator for a class", 0) != -1)
	{
		CustomAlert.error("Already a moderator has been assigned for this class. A class cannot have more than one moderator.");
	}
	//Generic error
	else
	{
		classRegistraionHelper.genericFaultHandler(event);
		closeCreateClassRegistrationComp();
	}
	//Fix for Bug # 1852 start
	btnSaveClassReg.enabled=true;
	//Fix for Bug # 1852 end
}

/**
 *
 * @public
 * This function is the result handler for updating class registration
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of ResultEvent
 * @return void
 *
 */
public function updateClassRegistrationResultHandler(event:ResultEvent):void
{
	hasClickedCancelButton=false;
	CustomAlert.info("Class registration updated successfully");
	closeCreateClassRegistrationComp();
}

/**
 *
 * @public
 * This function is the fault handler for updating class registration
 * This function is made public because the ClassRegistrationHelper.as will call this once it
 * gets the result from the server
 * @param event type of FaultEvent
 * @return void
 *
 */
public function updateClassRegistrationFaultHandler(event:FaultEvent):void
{
	createClassRegistrationFaultHandler(event);
}

/**
 *
 * @private
 * This function is to set the required status provider for a class registration
 *
 * @return void
 *
 */
private function setStatusesDataProvider():void
{
	var tmpAC:ArrayCollection=new ArrayCollection();
	ArrayCollectionUtil.copyData(tmpAC, GCLMContext.statusesAC);
	var i:int=0;
	//Do not display closed and deleted status provider for create class registration
	for (i=0; i < tmpAC.length; i++)
	{
		if ((tmpAC[i].statusId == StatusVO.CLOSED_STATUS) || (tmpAC[i].statusId == StatusVO.DELETED_STATUS))
		{
			tmpAC.removeItemAt(i);
			break;
		}
	}
	for (; i < tmpAC.length; i++)
	{
		if ((tmpAC[i].statusId == StatusVO.CLOSED_STATUS) || (tmpAC[i].statusId == StatusVO.DELETED_STATUS))
		{
			tmpAC.removeItemAt(i);
			break;
		}
	}
	classRegistrationStatusesAC=tmpAC;
	// Fix for Bug #14860
	cmbUserStatus.selectedIndex = -1;
}

/**
 *
 * @private
 * This function is to set appropriate status during edit
 * @param statusId type of Number
 * @return void
 *
 */
private function setUserStatus(statusId:Number):void
{
	//Fix for Bug # 6575 start
	//Iterate throgh the statuses to select the appropriate one to view during edit
	for (var i:int=0; i < classRegistrationStatusesAC.length; i++)
	{
		if (classRegistrationStatusesAC[i].statusId == statusId)
		{
			//Fix for Bug # 6575 end		
			break;
		}
	}
	cmbUserStatus.selectedIndex=i;
}

/**
 *
 * @private
 * This function is to hide the user status details
 *
 * @return void
 *
 */
private function hideUserStatus():void
{
	lblUserStatusImp.enabled=false;
	lblUserStatus.enabled=false;
	cmbUserStatus.enabled=false;
}

/**
 *
 * @private
 * This function is to reset the search criteria
 *
 * @return void
 *
 */
private function resetSmartCombos():void
{
	cmbClasses.filterString="";
	cmbClasses.selectedItem=null;
}

/**
 *
 * @private
 * This function is to set/reset moderator radio button group
 * @param isModerator type of Boolean
 * @return void
 *
 */
private function selectModerator(isModerator:Boolean):void
{
	rbYesModerator.selected=isModerator;
	rbNoModerator.selected=!isModerator;
}
/**
 *
 * @private
 * This function is called set/reset the checkbox of a particular module
 *
 * @return void
 *
 */
private function setModules():void
{
	chkModuleAudioVideo.selected=(classRegistration.enableAudioVideo == "Y");
	chkModuleDesktop.selected=(classRegistration.enableDesktopSharing == "Y");
	chkModuleDocument.selected=(classRegistration.enableDocumentSharing == "Y");
	chkModuleVideoSharing.selected=(classRegistration.enableVideoSharing == "Y");
	chkModule2D.selected=(classRegistration.enable2DSharing == "Y");
	chkModule3D.selected=(classRegistration.enable3DSharing == "Y");	
	setModulesAll();
}

/**
 *
 * @private
 * This function is to set the moderator radio button enabled/disabled, selec/deselect based
 * @param role type of String
 * @return void
 *
 */
private function setRBModerator(role:String):void
{
	//Enable the moderator radio button only if the role is teacher else disable
	if (role == Constants.TEACHER_TYPE)
	{
		//make the radio button selected only if the user is the moderator
		if (classRegistration.isModerator == "Y")
		{
			selectModerator(true);
		}
		else
		{
			selectModerator(false);
		}
		rbgIsModerator.enabled=true;
	}
	else
	{
		selectModerator(false);
		rbgIsModerator.enabled=false;
	}
}

/**
 *
 * @private
 * This function is to set/reset modulesAll radio button based on the selection
 *
 * @return void
 *
 */
private function setModulesAll():void
{
	//Check if all the modules have been selected. If so, mark the SelectAll check box as selected  
	if (chkModuleAudioVideo.selected && chkModuleDesktop.selected && chkModuleDocument.selected && chkModuleVideoSharing.selected && chkModule2D.selected && chkModule3D.selected)
	{
		chkModulesAll.selected=true;
	}
	else
	{
		chkModulesAll.selected=false;
	}
}

/**
 *
 * @private
 * This function to handle click of module radio button
 * @param event type of MouseEvent
 * @return void
 *
 */
private function moduleClickHandler(event:MouseEvent):void
{
	setModulesAll()
}

/**
 *
 * @private
 * This function to populate the selected class registration
 *
 * @return void
 *
 */
private function populateClassRegisterData():void
{
	var i:int=0;
	
	txtInpUserName.text=classRegistration.user.userName;
	//Iterate through the class array collection to select the exact class for editing
	for (i=0; i < classesAC.length; i++)
	{
		if (classRegistration.aviewClass.classId == classesAC[i].classId)
		{
			cmbClasses.selectedIndex=i;
			cmbClasses.selectedItem=classesAC[i];
			setCourseAndInstitute();
			break;
		}
	}
	setRBModerator(classRegistration.user.role);
	//Check the node type opted during class registration and set it accordingly.
	if (classRegistration.nodeTypeId == GCLMContext.PC_NODE_TYPE)
	{
		rbPersonalComputer.selected=true;
		rbClassroom.selected=false;
	}
	else if (classRegistration.nodeTypeId == GCLMContext.CR_NODE_TYPE)
	{
		rbPersonalComputer.selected=false;
		rbClassroom.selected=true;
	}
	setUserDetailsLabel(classRegistration.user.fname, classRegistration.user.lname, classRegistration.user.role, classRegistration.user.instituteName);
	setUserStatus(classRegistration.statusId);
	setModules();
}

/**
 *
 * @private
 * This function to set the course and institute during update
 *
 * @return void
 *
 */
private function setCourseAndInstitute():void
{
	//Check for empty and null values
	if ((cmbClasses.text != "") && (cmbClasses.selectedItem != null) && (cmbClasses.selectedItem.classId != 0))
	{
		//Check for not null
		if (cmbClasses.selectedItem.courseName != null)
		{
			lblCourseName.text=cmbClasses.selectedItem.courseName
		}
		//Check for not null
		if (cmbClasses.selectedItem.instituteName != null)
		{
			lblInstituteName.text=cmbClasses.selectedItem.instituteName;
			lblInstituteName.toolTip=lblInstituteName.text;
		}
	}
}

/**
 *
 * @private
 * This function to clear all the data in this window
 *
 * @return void
 *
 */
private function resetUser():void
{
	classRegistration.user=null;
	lblUserDetails.text="";
	lblErrorUser.text="";
	setRBModerator(ClassroomContext.userVO.role);
	btnSaveClassReg.enabled=false;
	btnValidate.enabled=true;
}

/**
 *
 * @private
 * This function to check if an user exists for the given user name
 *
 * @return void
 *
 */
private function checkUser():void
{
	btnValidate.enabled=false;
	userHelper.getUserByUserName(txtInpUserName.text,getUserByUserNameResultHandler);
}

/**
 *
 * @private
 * This function to set the user details
 * @param fName type of String
 * @param lName type of String
 * @param role type of String
 * @param instituteName type of String
 * @return void
 *
 */
private function setUserDetailsLabel(fName:String, lName:String, role:String, instituteName:String):void
{
	lblUserDetails.text=fName + " " + lName + " ( " + role + " from " + instituteName + " )";
	lblUserDetails.toolTip=lblUserDetails.text;
}

/**
 *
 * @private
 * This function to validate the data before creating a new class registratoin
 *
 * @return Boolean
 *
 */
private function validateDataFields():Boolean
{
	var result:Boolean=true;
	errorMessage="Please fill in the following fields: ";
	//Check for not null value 
	if (classRegistration.user == null)
	{
		errorMessage+="User Name, ";
		result=false;
	}
	//Check for empty and not null value 
	if ((cmbClasses.text == "") || (cmbClasses.selectedItem == null) || (cmbClasses.selectedItem.classId == 0))
	{
		errorMessage+="Class Name, ";
		result=false;
	}
	//Check for null value 
	//Fix for Bug #14860
	if (cmbUserStatus.selectedIndex < 0)
	{
		errorMessage+="User Status, ";
		result=false;
	}
	errorMessage=errorMessage.substring(0, errorMessage.lastIndexOf(","));
	return result;
}

/**
 *
 * @private
 * This function to save the new class registratoin
 *
 * @return void
 *
 */
private function saveClassRegistration():void
{
	if (validateDataFields())
	{
		//Fix for Bug # 1852 start
		btnSaveClassReg.enabled=false;
		//Fix for Bug # 1852 end
		classRegistration.aviewClass=new ClassVO();
		classRegistration.aviewClass.classId=cmbClasses.selectedItem.classId;
		classRegistration.aviewClass.className=cmbClasses.selectedItem.className;
		classRegistration.statusId=classRegistrationStatusesAC[cmbUserStatus.selectedIndex].statusId;
		statusId=classRegistrationStatusesAC[cmbUserStatus.selectedIndex].statusId;
		//Set the moderator to true, if the selected user is a teache and he is the moderator for the class
		if (classRegistration.user.role == Constants.TEACHER_TYPE)
		{
			classRegistration.isModerator=(rbYesModerator.selected) ? "Y" : "N";
		}
		else
		{
			classRegistration.isModerator="N";
		}
		
		//Check for changes..
		// Fix for Bug #19717 start 
		if ((ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) ||(ClassroomContext.userVO.role == Constants.MONITOR_TYPE) && !isUserRegistration && (((classRegistration.enableAudioVideo == "Y") != chkModuleAudioVideo.selected) || ((classRegistration.enableDesktopSharing == "Y") != chkModuleDesktop.selected) || ((classRegistration.enableDocumentSharing == "Y") != chkModuleDocument.selected) || ((classRegistration.enableVideoSharing == "Y") != chkModuleVideoSharing.selected) || ((classRegistration.enable2DSharing == "Y") != chkModule2D.selected) || ((classRegistration.enable3DSharing == "Y") != chkModule3D.selected)))
		// Fix for Bug #19717 end
		{
			//Fix for Bug #14947
			CustomAlert.info("You are changing the module selection. You must exit the class room and re-enter for these changes to take effect.");
		}
		classRegistration.enableAudioVideo=(chkModuleAudioVideo.selected) ? "Y" : "N";
		classRegistration.enableDesktopSharing=(chkModuleDesktop.selected) ? "Y" : "N";
		classRegistration.enableDocumentSharing=(chkModuleDocument.selected) ? "Y" : "N";
		classRegistration.enableVideoSharing=(chkModuleVideoSharing.selected) ? "Y" : "N";
		classRegistration.enable2DSharing=(chkModule2D.selected) ? "Y" : "N";
		classRegistration.enable3DSharing=(chkModule3D.selected) ? "Y" : "N";
		classRegistration.nodeTypeId=(rbPersonalComputer.selected) ? GCLMContext.PC_NODE_TYPE : GCLMContext.CR_NODE_TYPE;
		//Based on the class register id value, perform create/edit
		if (classRegistration.classRegisterId == 0)
		{
			classRegistraionHelper.createClassRegistration(classRegistration, ClassroomContext.userVO.userId, statusId,createClassRegistrationResultHandler,createClassRegistrationFaultHandler);
		}
		else
		{
			classRegistraionHelper.updateClassRegistration(classRegistration, ClassroomContext.userVO.userId,updateClassRegistrationResultHandler ,updateClassRegistrationFaultHandler);
		}
	}
	else
	{
		CustomAlert.error(errorMessage);
	}
}

/**
 *
 * @private
 * This function to close the CreateClassRegistrationComp window
 *
 * @return void
 *
 */
private function closeCreateClassRegistrationComp():void
{
	PopUpManager.removePopUp(this);
}

/**
 *
 * @protected
 * This function is called when selecting the all modules check box
 * @param event type of MouseEvent
 * @return void
 *
 */
protected function modulesAllClickHandler(event:MouseEvent):void
{
	chkModuleAudioVideo.selected=chkModulesAll.selected;
	chkModuleDesktop.selected=chkModulesAll.selected;
	chkModuleDocument.selected=chkModulesAll.selected;
	chkModuleVideoSharing.selected=chkModulesAll.selected;
	chkModule2D.selected=chkModulesAll.selected;
	chkModule3D.selected=chkModulesAll.selected;
}
