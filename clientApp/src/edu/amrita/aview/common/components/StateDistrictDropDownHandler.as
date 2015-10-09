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
 * File			: StateDistrictDropDownHandler.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 * The handler for StateDistrictDropDown.mxml
 */

//MMCR:-Function description for all function
//VGCR:-Description for bindable variables
import edu.amrita.aview.core.gclm.GCLMContext;
import edu.amrita.aview.common.util.ArrayCollectionUtil;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.utils.ObjectUtil;

import spark.collections.Sort;
import spark.collections.SortField;

[Bindable]
public var cmbwidth:Number=0;

[Bindable]
public var cmbHeight:Number=0;

[Bindable]
private var _districtsAC:ArrayCollection;

[Bindable]
private var statesAC:ArrayCollection;

/**
 *
 * @public
 *
 *
 * @return ArrayCollection
 */
public function get districtsAC():ArrayCollection
{
	return _districtsAC;
}

/**
 *
 * @public
 *
 * @param ac type of ArrayCollection
 * @return void
 */
[Bindable]
public function set districtsAC(ac:ArrayCollection):void
{
	_districtsAC=ObjectUtil.copy(ac) as ArrayCollection;
	sortData();
	_districtsAC.filterFunction=setDistricts;
	refreshDistricts();
}
/**
 *
 * @public
 *
 * @param stateName type of String
 * @param districtId type of Number
 * @param stateId type of number
 * @return void
 */
public function selectStateDistrict(stateName:String, districtId:Number, stateId:Number=0):void
{
	var j:int=0;
	for (j=0; j < statesAC.length; j++)
	{
		if (stateName == statesAC[j].stateName)
		{
			statesCB.selectedItem=statesAC[j];
			statesCB.selectedIndex=j;
			break;
		}
	}
	refreshDistricts();
	var tmpDistrictAC:ArrayCollection=districtsCB.dataProvider as ArrayCollection;
	for (j=0; j < tmpDistrictAC.length; j++)
	{
		if (tmpDistrictAC[j].districtId == districtId)
		{
			districtsCB.selectedIndex=j;
			break;
		}
	}
	//Fix for bug #5213 start
	if (j == tmpDistrictAC.length)
	{
		setDefaultDistrictText();
	}
	//Fix for bug #5213 start
}
/**
 *
 * @private
 *
 *
 * @return void
 */
private function sortData():void
{
	var dataSortField:SortField=new SortField();
	dataSortField.name="districtName";
	dataSortField.numeric=false;
	
	/** Create the Sort object and add the SortField object created earlier
	 *  to the array of fields to sort on.
	 */ 
	var dataSort:Sort=new Sort();
	dataSort.fields=[dataSortField];
	_districtsAC.sort=dataSort;
}

/**
 *
 * @private
 *
 *
 * @return void
 */
private function getDistrictsCombo():void
{
	
	if (districtsCB.selectedItem != null)
	{
		selectStateDistrict(statesCB.text, districtsCB.selectedItem.districtId);
	}
	else
	{
		refreshDistricts();
		setDefaultDistrictText();
	}
	districtsCB.setFocus();
}

/**
 *
 * @private
 *
 *
 * @return void
 */
private function refreshDistricts():void
{
	districtsAC.refresh();
}

/**
 *
 * @private
 *
 *
 * @return void
 *
 */
private function setDefaultDistrictText():void
{
	districtsCB.prompt="Select";
}

/**
 *
 * @private
 *
 * @param district type of Object
 * @return Boolean
 */
private function setDistricts(district:Object):Boolean
{
	var result:Boolean=false;
	if ((statesCB.text != "") && (statesCB.selectedItem != null) && (statesCB.selectedItem.stateId != 0))
	{
		// AKCR: the following 2 if conditions can be combined togther with a logical OR. for e.g
		// if (district.districtId == 0 || district.stateId == statesCB.selectedItem.stateId) 
		//     result = true;

		if (district.districtId == 0)
		{
			result=true;
		}
		else if (district.stateId == statesCB.selectedItem.stateId)
		{
			result=true;
			
		}
	}
	return result;
}



/**
 *
 * @protected
 *
 * @param event of FlexEvent
 * @return void
 */
protected function preinitializeHandler(event:FlexEvent):void
{
	// TODO Auto-generated method stub
	statesAC=new ArrayCollection();
	ArrayCollectionUtil.copyData(statesAC, GCLMContext.statesAC);
	districtsAC=new ArrayCollection();
}
