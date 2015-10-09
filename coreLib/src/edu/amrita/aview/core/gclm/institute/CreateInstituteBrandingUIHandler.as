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
 * File			: CreateInstituteBrandingUIHandler.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G
 * Reviewer(s)	: Swati, Abhirami, Sivaram SK
 *
 * This file is the script handler for CreateInstituteBranding.mxml
 *
 */
import mx.core.FlexGlobals;
import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;

import edu.amrita.aview.core.shared.components.alert.CustomAlert;
import edu.amrita.aview.core.gclm.events.InstituteBrandingSelectedEvent;
import edu.amrita.aview.core.gclm.vo.BrandingAttributeVO;
import edu.amrita.aview.core.gclm.vo.InstituteBrandingVO;


import mx.logging.ILogger;
import mx.logging.Log;


/**
 * Title for Create Institute Branding parent panel
 */
[Bindable]
public var instituteBrandingTitle:String=" Branding for the Institute ";
/**
 * The institute id for which the branding is done
 */
[Bindable]
public var instituteId:Number=0;
/**
 * To store the branding details
 */
private var instituteBrandings:ArrayCollection=null;
/**
 * To check whether Add brading logo is populated or not
 */
public var isUploadValid:Boolean=false;
/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.gclm.institute.CreateInstituteBrandingUIHandler.as");

/**
 *
 * @public
 * This function sets all the initial info required for the CreateInstituteBranding
 * This function is called from CreateInstituteCompUIHandler.as
 * @param existingBrandings : the existingBrandings details in case of edit
 * @return void
 *
 ***/
public function init(existingBrandings:ArrayCollection):void
{
	if (existingBrandings != null)
	{
		instituteBrandings=existingBrandings;
		populateBrandings();
	}
	else
	{
		instituteBrandings=new ArrayCollection();
	}
}

/**
 *
 * @private
 * This function is used to populate the existing branding details
 * @param event : null
 * @return void
 *
 ***/
private function populateBrandings():void
{
	var instituteBranding:InstituteBrandingVO=null;
	for (var i:int=0; i < instituteBrandings.length; i++)
	{
		instituteBranding=instituteBrandings.getItemAt(i) as InstituteBrandingVO;
		if (instituteBranding.brandingAttribute.brandingAttributeName == BrandingAttributeVO.LOGO)
		{
			uplLogo.uploadFile=instituteBranding.brandingAttributeValue;
			// Fix for bug 19806
		    isUploadValid=true;

		}
		else if (instituteBranding.brandingAttribute.brandingAttributeName == BrandingAttributeVO.STYLE_SHEET)
		{
			uplStyle.uploadFile=instituteBranding.brandingAttributeValue;
		}
	}
}

/**
 *
 * @private
 * This function is used to validate the data before saving
 * @param event : null
 * @return void
 *
 ***/
private function validate():Boolean
{
	var valid:Boolean=true;
	var errorMessage:String="";
	if (uplLogo.uploadFile != "")
	{
		// Fix for bug 19806
		if (!isUploadValid && uplLogo.progressBar.percentComplete != 100 )
		{
			errorMessage="Please wait till Logo upload is complete"

		}
	}
	if (uplStyle.uploadFile != "")
	{
		if (uplStyle.progressBar.percentComplete != 100)
		{
			errorMessage=errorMessage + "\n" + "Please wait till Stylesheet upload is complete";
		}
	}

	if (errorMessage.length > 0)
	{
		CustomAlert.info(errorMessage);
		valid=false;
	}
	return valid;
}

/**
 *
 * @private
 * This function is used to get the branding value based on the branding name
 * @param brandingAttributeName : the brandingAttribute
 * @return InstituteBrandingVO object or null if the given branding attribute name is not avaiable
 *
 ***/
private function getOriginalBrandingValue(brandingAttributeName:String):InstituteBrandingVO
{
	var instituteBranding:InstituteBrandingVO=null;
	for (var i:int=0; i < instituteBrandings.length; i++)
	{
		instituteBranding=instituteBrandings.getItemAt(i) as InstituteBrandingVO;
		if (instituteBranding.brandingAttribute.brandingAttributeName == brandingAttributeName)
		{
			return instituteBranding;
		}
	}
	return null;
}

/**
 *
 * @private
 * This function is used to save the branding details
 * @param brandingAttributeName : the brandingAttribute
 * @return InstituteBrandingVO object or null
 *
 ***/
private function saveInstituteBranding():void
{
	if(Log.isDebug()) log.debug("Coming inside save institute admins");

	if (!validate())
	{
		return;
	}
	var savedBrandings:ArrayCollection=new ArrayCollection();
	//If user entered logo uploading file is not null
	if (uplLogo.progressBar.visible && uplLogo.uploadFile != "")
	{
		var logoBranding:InstituteBrandingVO=getOriginalBrandingValue(BrandingAttributeVO.LOGO);
		// If logoBranding is null then initialise it
		if (logoBranding == null)
		{
			logoBranding=new InstituteBrandingVO();
			logoBranding.brandingAttribute=BrandingAttributeVO.logoBrandingAttributeVO;
		}
		logoBranding.brandingAttributeValue=uplLogo.uploadFile;
		savedBrandings.addItem(logoBranding);
	}

	//If user entered style uploading file is not null
	if (uplStyle.progressBar.visible && uplStyle.uploadFile != "")
	{
		var styleBranding:InstituteBrandingVO=getOriginalBrandingValue(BrandingAttributeVO.STYLE_SHEET);
		// If styleBranding is null then initialise it
		if (styleBranding == null)
		{
			styleBranding=new InstituteBrandingVO();
			styleBranding.brandingAttribute=BrandingAttributeVO.styleBrandingAttributeVO;
		}
		styleBranding.brandingAttributeValue=uplStyle.uploadFile;
		savedBrandings.addItem(styleBranding);
	}
	//dispatch the branding selected event once it is done
	this.dispatchEvent(new InstituteBrandingSelectedEvent(InstituteBrandingSelectedEvent.INSTITUTE_BRANDING_SELECTED, false, false, savedBrandings));
	removeInstituteBrandingComp();
}

/**
 *
 * @private
 * This function is to close the CreateInstiuteBranding window
 *
 * @return void
 *
 ***/
private function removeInstituteBrandingComp():void
{
	if(Log.isDebug()) log.debug("Removing Save Institute Admin comp");
	PopUpManager.removePopUp(this);
}