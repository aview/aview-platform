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
 * File			: CreateUserCompUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	:
 */
import com.adobe.crypto.SHA1;

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.shared.helper.AbstractHelper;
import edu.amrita.aview.core.shared.vo.StatusVO;
import edu.amrita.aview.core.entry.ClassroomContext;
import edu.amrita.aview.core.entry.Constants;
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.core.gclm.helper.UserHelper;
import edu.amrita.aview.core.gclm.vo.UserVO;

import mx.core.FlexGlobals;
import mx.events.ValidationResultEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

/**
 *  To track if the cancel button is clicked 
 */
public var hasClickedCancelButton:Boolean;
[Bindable]
private var userRoles:Array;
/**
 *  The error message to display during validation 
 */
private var errMsg:String="";

/**
 *  The user vo object instance
 */
private var user:UserVO;

/**
 *  To track if the user has entered a valid email 
 */
private var isValidEmail:Boolean=true;

/**
 *  The helper class instance to communicate to the server 
 */
private static const CLIENT_CREATION_TYPE : String = "Client";
private var userHelper:UserHelper=null;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.user.CreateUserCompUIHandler.as");

/**
 * @public
 * This function sets all the initial info that is required for the Create User Comp.
 * This is invoked from the UserCome
 * @param userVO type of UserVO default=null
 * @return void
 */
public function init(userVO:UserVO=null):void
{
	isValidEmail=true;
	userHelper=new UserHelper();
	userRoles=new Array();
	//In case of edit, if the user is not an adminstrator, the only visible role is the user's role itself
	//Teachers/Students cant change their role by themselves
	if (ClassroomContext.userVO.role == Constants.STUDENT_TYPE || 
		ClassroomContext.userVO.role == Constants.TEACHER_TYPE ||
		ClassroomContext.userVO.role == Constants.MONITOR_TYPE)
			
	{
		userRoles.push(ClassroomContext.userVO.role);
	}
	//If the user is institute admin/master admin, they can create users of type teacher/student/monitor
	else if ( (ClassroomContext.userVO.role == Constants.ADMIN_TYPE) || 
		      (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE) )
	{
		userRoles.push(Constants.STUDENT_TYPE);
		userRoles.push(Constants.TEACHER_TYPE);
		// New role monitor type is added for monitoring the class
		userRoles.push(Constants.MONITOR_TYPE);
		if(ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)
		{
			userRoles.push(Constants.ADMIN_TYPE);
		}
	}
		
	hasClickedCancelButton=true;
	user=new UserVO();
	//Check if edit or create based on the null value
	if (userVO != null)
	{
		user=ObjectUtil.copy(userVO) as UserVO;
		populateData();
	}
	else
	{
		resetSmartCombos();
		cmbUserRole.selectedIndex=0;
	}
}

/**
 * @public
 * This function is the result handler for updating user details
 * event - the result event from the server
 * @param event type of ResultEvent
 * @return void
 */
public function updateUserResultHandler(event:ResultEvent):void
{
	CustomAlert.info("User updated successfully");
	hasClickedCancelButton=false;
	closeCreateUserComp();
}

/**
 * @public
 * This function is the fault handler while updating user details
 * event - the fault event from the server
 * @param event type of FaultEvent
 * @return void
 */
public function updateUserFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::user::CreateUserCompUIHandler::updateUserFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	var strMsg:String=event.fault.faultString;
	//Check if the error is due to duplicate entry
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given user name already exists. Please try a different user name");
		//Fix for Bug # 1852 start
		btnSaveUser.enabled=true;
			//Fix for Bug # 1852 end
	}
	else
	{
		userHelper.genericFaultHandler(event);
		closeCreateUserComp();
	}
}

/**
 * @public
 * This function is the result handler for creating user details
 * event - the result event from the server
 * @param event type of ResultEvent
 * @return void
 */
public function createUserResultHandler(event:ResultEvent):void
{
	CustomAlert.info("User created successfully");
	hasClickedCancelButton=false;
	closeCreateUserComp();
}

/**
 * @public
 * This function is the fault handler while creating user details
 * event - the fault event from the server
 * @param event type of FaultEvent
 * @return void
 */
public function createUserFaultHandler(event:FaultEvent):void
{
	if(Log.isError()) log.error("gclm::user::CreateUserCompUIHandler::createUserFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
	hasClickedCancelButton=false;
	var strMsg:String=event.fault.faultString;
	//Check if the error is due to duplicate entry
	if (strMsg.indexOf("Duplicate entry", 0) != -1)
	{
		CustomAlert.error("The given user name already exists. Please try a different user name");
		//Fix for Bug # 1852 start
		btnSaveUser.enabled=true;
			//Fix for Bug # 1852 end
	}
	else
	{
		userHelper.genericFaultHandler(event);
		closeCreateUserComp();
	}
}

/**
 * @private
 * This function is to reset all the search criteria
 *
 * @return void
 */
private function resetSmartCombos():void
{
	edtCmbInstituteName.filterString="";
	edtCmbInstituteName.selectedItem=null;
}

/**
 * @private
 * This function is to populate all the user details (during edit) to the appropriate controls
 *
 * @return void
 */
private function populateData():void
{
	var i:int=0;
	txtInpUserName.text=user.userName;
	// Fix for Bug # 11023 start
	//Disable the user name text while editing
	txtInpUserName.enabled=false;
	// Fix for Bug # 11023 end
	txtInpPassword.text=user.password;
	txtInpConfirmPassword.text=user.password;
	txtInpPassword.enabled=false;
	txtInpConfirmPassword.enabled=false;
	txtInpFirstName.text=user.fname;
	txtInpLastName.text=user.lname;
	//Check for null value
	if (user.address != null)
	{
		txtAreaUserAddress.text=user.address;
	}
	//Check for null value
	if (user.zipId != null)
	{
		txtInpZipCode.text=user.zipId;
	}
	//Check for null value
	if (user.mobileNumber != null)
	{
		txtInpMobileNumber.text=user.mobileNumber;
	}
	else
	{
		txtInpMobileNumber.text='';
	}
	//Check for null value
	if (user.email != null)
	{
		txtInpEmail.text=user.email;
	}
	else
	{
		txtInpEmail.text='';
	}
	//Check for null value
	if (user.instituteName != null)
	{
		//Check if the logged in user is teacher/student/monitor.
		//Fix for Bug#19577 :Added Monitor role in this check
		if ((ClassroomContext.userVO.role == Constants.TEACHER_TYPE) || (ClassroomContext.userVO.role == Constants.STUDENT_TYPE) || (ClassroomContext.userVO.role == Constants.MONITOR_TYPE))
		{
			edtCmbInstituteName.visible=false;
			lblInstituteName.visible=true;
			lblInstituteName.text=user.instituteName;
		}
		else
		{
			//Mark the user institute as selected item
			for (i=0; i < GCLMContext.allInstitutesAC.length; i++)
			{
				if (GCLMContext.allInstitutesAC[i].instituteId == user.instituteId)
				{
					break;
				}
			}
			// Fix for Bug #10222 start
			if (i < GCLMContext.allInstitutesAC.length)
			{
				edtCmbInstituteName.selectedIndex=i;
				edtCmbInstituteName.selectedItem=GCLMContext.allInstitutesAC[i];
			}
				// Fix for Bug #10222 end
		}
	}
	//Set the district and state details
	if ((user.districtName != null) && (user.districtId != 0) && (user.stateName != null))
	{
		stateDistrict.selectStateDistrict(user.stateName, user.districtId);
	}
	txtInpCity.text=user.city;
	
	//Editing Self..User can't change their role
	if (user.userName == ClassroomContext.userVO.userName)
	{
		if (user.role == Constants.ADMIN_TYPE)
		{
			userRoles.push(Constants.ADMIN_TYPE);
		}
		else if (user.role == Constants.MASTER_ADMIN_TYPE)
		{
			userRoles.push(Constants.MASTER_ADMIN_TYPE);
		}
		disableUserRoleCombo();
	}
	cmbUserRole.selectedIndex=userRoles.indexOf(user.role);
}

/**
 * @private
 * This function disables the role change combo box in case if the user does self editing
 *
 * @return void
 */
private function disableUserRoleCombo():void
{
	//Editing Self..User can't change their role
	if (user.userId == ClassroomContext.userVO.userId)
	{
		cmbUserRole.enabled=false;
	}
}

/**
 * @private
 * This function is the initial call to save the user at the server
 *
 * @return void
 */
private function saveUser():void
{
	if(Log.isDebug()) log.debug("Coming inside save user");
	if (validateUserDetails())
	{
		//Fix for Bug # 1852 start
		btnSaveUser.enabled=false;
		//Fix for Bug # 1852 end
		user.userName=txtInpUserName.text;
		//Check if the password input is valid
		if (txtInpPassword.enabled)
		{
			user.password=SHA1.hash(txtInpPassword.text);
		}
		else
		{
			user.password=txtInpPassword.text;
		}
		user.fname=txtInpFirstName.text;
		user.lname=txtInpLastName.text;
		user.mobileNumber=txtInpMobileNumber.text;
		user.email=txtInpEmail.text;
		//Check for empty and not null value
		if ((edtCmbInstituteName.selectedItem != null) && (edtCmbInstituteName.selectedItem.instituteId != 0))
		{
			user.instituteId=edtCmbInstituteName.selectedItem.instituteId;
			user.instituteName=edtCmbInstituteName.selectedItem.instituteName;
		}
		//Check for empty and not null value
		if ((stateDistrict.statesCB.selectedItem != null) && (stateDistrict.statesCB.selectedItem.stateId != 0))
		{
			user.stateName=stateDistrict.statesCB.selectedItem.stateName;
			user.stateId=stateDistrict.statesCB.selectedItem.stateId;
		}
		//Check for empty and not null value
		if ((stateDistrict.districtsCB.selectedItem != null) && (stateDistrict.districtsCB.selectedItem.districtId != 0))
		{
			user.districtName=stateDistrict.districtsCB.selectedItem.districtName;
			user.districtId=stateDistrict.districtsCB.selectedItem.districtId;
		}
		user.city=txtInpCity.text;
		//Check for empty value
		if (txtInpZipCode.text != '')
		{
			user.zipId=txtInpZipCode.text;
		}
		//Check for empty value
		if (txtAreaUserAddress.text != '')
		{
			user.address=txtAreaUserAddress.text;
		}
		//user.role = Constants.USER_ROLE[cmbUserRole.selectedIndex];
		user.role=userRoles[cmbUserRole.selectedIndex];
		user.createdFrom = CLIENT_CREATION_TYPE;
		//Perform edit/create based on the user id
		if (user.userId == 0)
		{
			userHelper.createUser(user, ClassroomContext.userVO.userId, StatusVO.ACTIVE_STATUS,createUserResultHandler,createUserFaultHandler);
		}
		else
		{
			userHelper.updateUser(user, ClassroomContext.userVO.userId,updateUserResultHandler ,updateUserFaultHandler);
		}
	}
	else
	{
		CustomAlert.error(errMsg);
	}
}

/**
 * @private
 * This function is to validate the user filled in details
 *
 * @return Boolean
 */
private function validateUserDetails():Boolean
{
	var result:Boolean=true;
	errMsg="";
	//Check for empty value
	if (txtInpUserName.text == "")
	{
		errMsg+="\n User Name, ";
		result=false;
	}
	//Check for empty value
	if (txtInpPassword.text == '')
	{
		errMsg+="\n Password, ";
		result=false;
	}
	//Check for empty value
	if (txtInpConfirmPassword.text == '')
	{
		errMsg+="\n Confirm Password, ";
		result=false;
	}
	//Check for empty value
	if (txtInpFirstName.text == '')
	{
		errMsg+="\n First Name, ";
		result=false;
	}
	//Check for empty value
	if (txtInpLastName.text == '')
	{
		errMsg+="\n Last Name, ";
		result=false;
	}
	//Check for empty value
	if (txtInpMobileNumber.text == '')
	{
		errMsg+="\n Mobile Number, ";
		result=false;
	}
	//Check for empty value
	else if (txtInpMobileNumber.text.length != 10)
	{
		errMsg+="\n Mobile Number should have 10 digits, ";
		result=false;
	}
	//Check for empty value
	if (txtInpEmail.text == '')
	{
		errMsg+="\n Email, ";
		result=false;
	}
	//Check for empty value
	if (((ClassroomContext.userVO.role == Constants.ADMIN_TYPE) || (ClassroomContext.userVO.role == Constants.MASTER_ADMIN_TYPE)) && ((edtCmbInstituteName.text == "") || (edtCmbInstituteName.selectedItem == null) || (edtCmbInstituteName.selectedItem.instituteId == 0)))
	{
		errMsg+="\n Institute Name, ";
		result=false;
	}
	//Check for empty value
	if (txtInpCity.text == '')
	{
		errMsg+="\n City, ";
		result=false;
	}
	//Check for empty value
	if (txtInpZipCode.text == '')
	{
		errMsg+="\n Pincode,";
		result=false;
	}
	//Fix for Bug #7488 start
	if ((txtInpZipCode.text != '') && (txtInpZipCode.text.length != 6))
	{
		errMsg+="\n Pincode should have 6 digits, ";
		result=false;
	}
	//Fix for Bug #7488 end
	if (txtAreaUserAddress.text == '')
	{
		errMsg+="\n Address, ";
		result=false;
	}
	//Check for empty value
	if ((stateDistrict.statesCB.text == "") || (stateDistrict.statesCB.selectedItem == null) || (stateDistrict.statesCB.selectedItem.stateId == 0))
	{
		errMsg+="\n State, ";
		result=false;
	}
	//Check for empty value
	if ((stateDistrict.districtsCB.selectedIndex == -1) || (stateDistrict.districtsCB.selectedItem == null) || (stateDistrict.districtsCB.selectedItem.districtId == 0))
	{
		errMsg+="\n District, ";
		result=false;
	}
	if(errMsg != "")
	{
		errMsg = "Please fill the following fields:"+ errMsg;
		errMsg = errMsg.substring(0, errMsg.lastIndexOf(","));
	}
	//Fix  for Bug #13867 start
	//To check if the user is creating password for the first time. If not, ignore 
	//the password validation
	if(txtInpPassword.text != '' && !Constants.PASSWORD_STRENGTH_REGEXP.test(txtInpPassword.text) && (user.userId == 0))
	{
		errMsg += "\nNew password must contain atleast 8 characters with atleast one upper case letter, one lower case letter, one digit and one special character";
		result = false;
	}
	else if(txtInpPassword.text != txtInpConfirmPassword.text)
	{
		errMsg += "\nPassword and Confirm password text do not match";
		result = false;
	}
	//Check of email id is valid
	if (!isValidEmail)
	{
		errMsg="\nPlease enter a valid email id";
		result=false;
	}
	return result;
}

/**
 * @private
 * This function is the result handler for email validator
 * @param event type of ValidationResultEvent
 * @return void
 */
private function emailValidationHandler(event:ValidationResultEvent):void
{
	//Check the event for not null value as result
	if ((event.results != null) && (event.results[0].isError))
	{
		isValidEmail=false;
	}
	else if (event.type == "valid")
	{
		isValidEmail=true;
	}
}


/**
* @private
* This function is called when the user tries to close the create comp window
* @param null
* @return void
*/
private function closeCreateUserComp():void
{
//	institutesAC.removeAll();
	if(Log.isDebug()) log.debug("Create user comp closed");
	PopUpManager.removePopUp(this);
}