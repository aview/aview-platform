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
 * File			: QuizSummaryUIHandler.as
 * Module		: Evaluation
 * Developer(s)	: Sethu subramanian N, Abhirami, Swati, Radha, Mathiyalakan.
 * Reviewer(s)	: Vinod Kumar P
 *
 * This component displays summary of quizzes
 *
 */

import edu.amrita.aview.core.shared.components.ArrayCollectionExtended;
import edu.amrita.aview.core.shared.util.AViewStringUtil;

import flash.events.FocusEvent;

import mx.controls.Alert;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.utils.StringUtil;

import spark.components.gridClasses.GridColumn;

/**
 *  Variable to hold list of quiz
 * */
[Bindable]
public var quizzes:ArrayCollectionExtended=new ArrayCollectionExtended;

/**
 * For debug log
 */
private var log:ILogger=Log.getLogger("aview.modules.evaluation.quiz.QuizSummaryUIHandler.as");

/**
 * @public
 * Sets initial data for displaying summary
 *
 * @return void
 */
public function init():void {
	//Fix for Bug #18899:Start
	//filterByDate is used instead of filterByTimeOpen & filterByTimeClose
	quizzes.filterFunctions=[filterByQuizName, filterByClassName, filterByQPName, filterByDate];
	//Fix for Bug #18899:End
	quizzes.refresh();
}

/**
 * @public
 * Gets the quizzes
 * @return ArrayCollectionExtended
 *
 */
public function get quizAC():ArrayCollectionExtended {
	return quizzes;
}

/**
 * @public
 * Sets the quizzes
 * @param ac type of ArrayCollectionExtended
 * @return void
 */
public function set quizAC(ac:ArrayCollectionExtended):void {
	this.quizzes=ac;
}

/**
 * @private
 * Filter function to filter by quiz name
 * @param item type of Object
 * @return boolean
 *
 */
private function filterByQuizName(item:Object):Boolean {
	/* Check whether the quiz name in item object is same as text in txtQuizNameSearch. */
	if ((StringUtil.trim(txtQuizNameSearch.text) == null) || (item.quizName.toLowerCase().indexOf(txtQuizNameSearch.text.toLowerCase()) != -1)) {
		return true;
	}
	return false;
}

/**
 * @private
 * Filter function to filter by class name
 * @param item type of Object
 * @return boolean
 *
 */
private function filterByClassName(item:Object):Boolean {
	/* Check whether the class name in item object is same as text in txtClassNameSearch. */
	if ((StringUtil.trim(txtClassNameSearch.text) == null) || (item.className.toLowerCase().indexOf(txtClassNameSearch.text.toLowerCase()) != -1)) {
		return true;
	}
	return false;
}

/**
 * @private
 * Filter function to filter by Question Paper name
 * @param item type of Object
 * @return boolean
 *
 */
private function filterByQPName(item:Object):Boolean {
	/* Check whether the question paper name in item object is same as text in txtQPNameSearch. */
	if ((StringUtil.trim(txtQPNameSearch.text) == null) || (item.questionPaperName.toLowerCase().indexOf(txtQPNameSearch.text.toLowerCase()) != -1)) {
		return true;
	}
	return false;
}

//Fix for Bug #18899:Start
//filterByDate is used instead of filterByTimeOpen & filterByTimeClose
 /*
 private function filterByTimeOpen(item:Object):Boolean {
	if(Log.isDebug()) log.debug("dateFormatter1.format(timeOpen.text)::" + dateFormatter1.format(dateTimeOpen.selectedDate));
	if(Log.isDebug()) log.debug("dateFormatter1.format(item.timeOpen)::" + dateFormatter1.format(item.timeOpen));
	//Check whether the open time in item object is same as date in dateTimeOpen. 
	//if (dateTimeOpen.text == "" || (dateFormatter1.format(dateTimeOpen.selectedDate) == dateFormatter1.format(item.timeOpen))) {
		//return true;
	}
	return false;
} 

private function filterByTimeClose(item:Object):Boolean {
	//Check whether the close time in item object is same as date in dateTimeClose. 
	//if (dateTimeClose.text == "" || (dateFormatter1.format(dateTimeClose.selectedDate) == dateFormatter1.format(item.timeClose))) {
		//return true;
	}
	return false;
}*/
//Fix for Bug #18899:End

/**
 * @private
 * Format the date as string
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function formatTimeOpen(oItem:Object, iCol:int):String {
	return dateFormatter.format(oItem.timeOpen);
}

/**
  * @private
 * Format the date as string
 * @param oItem type of Object
 * @param iCol type of int
 * @return String
 *
 */
private function formatTimeClose(oItem:Object, iCol:int):String {
	return dateFormatter.format(oItem.timeClose);
}

/**
 * @private
 * Reset all components
 *
 * @return void
 */
private function resetFields():void {
	//fixed bug :#6272
	dateTimeOpen.text="";
	dateTimeClose.text="";
	txtQPNameSearch.text="";
	txtClassNameSearch.text="";
	txtQuizNameSearch.text="";
	//Fix for Bug #18899:Start
	dateTimeOpen.selectableRange=null;
	dateTimeOpen.selectedDate=null;
	dateTimeClose.selectableRange=null;
	dateTimeClose.selectedDate=null;
	//Fix for Bug #18899:End
	quizzes.refresh();
}

/**
 * @private
 * Search the list of quizzes as per quiz , class and question paper
 *
 * @return void
 */
private function searchHandler():void {
	// Validating user input.If it is not null then refresh 'quizzes' arraycollection.
	// Else reset all the fields.
	if ((StringUtil.trim(txtQuizNameSearch.text) != "") || (StringUtil.trim(txtClassNameSearch.text) != "") || (StringUtil.trim(txtQPNameSearch.text) != "")) {
		quizzes.refresh();
	} 
	//Fix for Bug #11005
	/*else {
		resetFields();
	}*/
}

/**
 * @private
 * Sets the default text on all combo box components
 *
 * @return void
 *
 */
private function focusOutHandlerForQuiz():void {
	/* If user entered input is null then set some message as watermark string. */
//	Fix for Bug #11005
	if (StringUtil.trim(txtQuizNameSearch.text) == "") {
		txtQuizNameSearch.setStyle("textAlign","center");;
//		txtQuizNameSearch.watermark="Search by quiz name";
	}
	if (StringUtil.trim(txtClassNameSearch.text) == "") {
		txtClassNameSearch.setStyle("textAlign","center");;
//		txtClassNameSearch.watermark="Search by class name";
	}
	if (StringUtil.trim(txtQPNameSearch.text) == "") {
		txtQPNameSearch.setStyle("textAlign","center");;
//		txtQPNameSearch.watermark="Search by question paper";
	}
	quizzes.refresh();
}

/**
 * @private
 * Sets the range of end date as the selected start date onwards
 *
 * @return void
 */
private function setEndDateRange():void 
{
	//Fix for Bug #18899:Start
	//Checking start date & end date are not null
	//returning alert message,if start date is greater than end date
	if(dateTimeClose.text!="" && dateTimeOpen.text!="")
	{
		if(dateTimeClose.selectedDate<dateTimeOpen.selectedDate)
		{
			Alert.show("Start date should be less than End date");
			return;
		}
	}
	//Setting end date range only start date is given
	if(dateTimeOpen.text!="" && dateTimeClose.text=="")
	{
		//dateTimeClose.text="";
		//Fix for Bug #11044
		//	dateTimeClose.selectedDate=null;
		//Fix for Bug #18899:End
		var dt:Date=new Date();
		if(Log.isDebug()) log.debug(""+ dt.date);
		// Checking dateTimeOpen is not null and not same as today's date
		//and setting selected date time to date
		if (dateTimeOpen.selectedDate != null ? dateTimeOpen.selectedDate.date != dt.date : false) 
		{
			dt.setTime(dateTimeOpen.selectedDate.getTime());
		} 
		//Setting dateTimeOpen to today date and time
		else 
		{
			dateTimeOpen.showToday=true;
			dt.setTime(dt.time);
			dateTimeOpen.selectedDate=new Date();
		}
		//Fix for Bug #18899:Start
		/*if(Log.isDebug())
		{
			log.debug(""+ dt);
		}*/
		//Fix for Bug #18899:End
		
		//Setting close date selectable range after date open
		dateTimeClose.selectableRange={rangeStart: dt};
		dateTimeClose.enabled=true;
	}
	//Fix for Bug #18899:Start
	quizzes.refresh();
	//Fix for Bug #18899:End
}
/**
 * @private
 * Filter function to filter by Date
 * @param item type of Object
 * @return boolean
 *
 */
private function filterByDate(item:Object):Boolean 
{
	if(Log.isDebug()) log.debug("dateFormatter1.format(timeOpen.text)::" + dateFormatter1.format(dateTimeOpen.selectedDate));
	if(Log.isDebug()) log.debug("dateFormatter1.format(item.timeOpen)::" + dateFormatter1.format(item.timeOpen));
	//Checking dateTimeOpen & dateTimeClose are null,and return all the values
	if(dateTimeOpen.text == "" && dateTimeClose.text =="")
	{
		return true;
	}
	// Check whether the open time in item object is same as date in dateTimeOpen. 
	//Return only the selected date for start date
	if (dateFormatter1.format(dateTimeOpen.selectedDate) == dateFormatter1.format(item.timeOpen)) 
	{
		return true;
	}
	// Check whether the close time in item object is same as date in dateTimeClose. 
	//Return only the selected date for end date
	else if (dateFormatter1.format(dateTimeClose.selectedDate) == dateFormatter1.format(item.timeClose)) 
	{
		return true;
	}
	//Checking dateTimeOpen & dateTimeClose are not null,
	//return in between values of dateTimeOpen & dateTimeClose,if dateTimeOpen is less than dateTimeClose
	if(dateTimeOpen.text!="" && dateTimeClose.text!="")
	{
		if(dateTimeOpen.selectedDate<dateTimeClose.selectedDate)
		{
			if( ((dateTimeOpen.selectedDate) <= (item.timeOpen)) && ((dateTimeClose.selectedDate) >=(item.timeClose)))
			{
				return true;
			}
		}
		
	}
	return false;	
}
//Fix for Bug #18899:End


//Fix for Bug#14821
//If sortCompare function doesn't exists(and labelFunction exists),it causes application crash when we click on that datagrid column.
//Fix for Bug#11215
//Both issues solved by adding datafield in grid column(Serial No:)
private function creationCompleteHandler():void
 {
	for(var i:int = 0;i < quizzes.length;i++)
	{
		quizzes[i].displayIndex = i+1;
	}
	quizzes.refresh();
 }
/**
 * 
 * @private
 * Function :focusInHandlerForQuiz
 * FocusIn handler for txtQuizNameSearch, txtClassNameSearch, txtQPNameSearch
 * @return void
 * 
 */
//Fix for Bug #11005
private function focusInHandlerForQuiz(event:FocusEvent):void 
{
	if(event.currentTarget == txtQuizNameSearch)
	{
		txtQuizNameSearch.setStyle("textAlign","left");
	}
	else if(event.currentTarget == txtClassNameSearch)
	{
		txtClassNameSearch.setStyle("textAlign","left");
	}
	else if(event.currentTarget == txtQPNameSearch)
	{
		txtQPNameSearch.setStyle("textAlign","left");
	}
}