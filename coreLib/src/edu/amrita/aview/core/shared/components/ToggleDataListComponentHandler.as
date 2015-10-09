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
 * File			: ToggleDataListComponentHandler.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 *
 */
//VGCR:-Description for Bindable variable
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.utils.ObjectUtil;

public var minSelection:int;
public var maxSelection:int;

[Bindable]
public var arrBW:ArrayCollection=new ArrayCollection();

[Bindable]
public var originalDataLabelField:String;

[Bindable]
public var selectedDataLabelField:String;

[Bindable]
private var _originalDataAC:ArrayCollection=new ArrayCollection();

[Bindable]
private var _selectedDataAC:ArrayCollection=new ArrayCollection();
/**
 *
 * @public
 * getter function for collecting the data
 *
 * @return ArrayCollection
 *
 */
[Bindable]
public function get originalDataAC():ArrayCollection
{
	return this._originalDataAC;
}

/**
 *
 * @public
 * setter function for collecting the data
 * @param originalDataAC type of ArrayCollection
 * @return void
 *
 */
public function set originalDataAC(originalDataAC:ArrayCollection):void
{
	//this._originalDataAC = ObjectUtil.copy(originalDataAC) as ArrayCollection;
	this._originalDataAC=originalDataAC;
}

/**
 *
 * @public
 * getter function for collecting the selected data
 *
 * @return ArrayCollection
 *
 */
[Bindable]
public function get selectedDataAC():ArrayCollection
{
	return this._selectedDataAC;
}

/**
 *
 * @public
 * setter function for collecting the selected data
 * @param selectedDataAC type of ArrayCollection
 * @return void
 *
 */
public function set selectedDataAC(selectedDataAC:ArrayCollection):void
{
	this._selectedDataAC=selectedDataAC;
}
/**
 *
 * @public
 * function for filtering the data 
 *
 * @return void
 *
 */
public function filterData():void
{
	var temp1:Object=new Object();
	var newArr:Array=new Array;
	var i:int=0;
	// AKCR: the following nested for loop code looks very inefficient.
	// AKCR: please document the logic and re-write to improve runtime performance
	for each (temp1 in selectedDataAC)
	{
		for each (var temp2:Object in selectedDataAC)
		{
			if (temp1.index == temp2.index)
				newArr.push(temp1);
			
			for (i=0; i < originalDataAC.length; i++)
			{
				if (temp2.index == originalDataAC[i].index)
				{
					originalDataAC.removeItemAt(i);
					break;
				}
			}
		}
	}
}
/**
 *
 * @private
 * function for adding the data to the arraycollection variable
 * @param arr type of ArrayCollection
 * @param src type of ArrayCollection
 * @return void
 *
 */
private function addAll(arr:ArrayCollection, src:ArrayCollection):void
{
	for each (var o:Object in src)
	{
		arr.addItem(ObjectUtil.copy(o) as Object);
	}
}

/**
 *
 * @private
 * function for adding the data to the arraycollection variable
 * @param arr type of ArrayCollection
 * @param src type of ArrayCollection
 * @return void
 *
 */
private function addToBWAll(arr:ArrayCollection, src:ArrayCollection):void
{
	// AKCR: the following code does not make sense. Can you please document and 
	// AKCR: explain the logic. Chances are we can re-write it for better performance 
	for each (var o:Object in src)
	{
		for each (var temp:Object in arrBW)
		{
			if (temp.index == o.index)
			{
				arr.addItem(temp);
			}
		}
	}
}

/**
 *
 * @private
 * function for sorting the selected items
 *
 * @return void
 *
 */
private function sortSelectedItems():void
{
	var s:Sort=new Sort();
	var sortFlag:Boolean=false;
	if (selectedDataAC.length > 0)
	{
		//Fix for Bug#15037
		var dataSortField:SortField = new SortField(selectedDataLabelField);
		dataSortField.numeric = false;
		dataSortField.caseInsensitive = true;
		
		s.fields=[dataSortField];
		selectedDataAC.sort=s;
		selectedDataAC.refresh();
	}
}

/**
 *
 * @private
 * function for sorting the available items
 *
 * @return void
 *
 */
private function sortAvailableItems():void
{
	var s:Sort=new Sort();
	var sortFlag:Boolean=false;
	if (originalDataAC.length > 0)
	{
		//Fix for Bug#15037
		var dataSortField:SortField = new SortField(originalDataLabelField);
		dataSortField.numeric = false;
		dataSortField.caseInsensitive = true;
		
		s.fields=[dataSortField];
		originalDataAC.sort=s;
		originalDataAC.refresh();
	}
}

/**
 *
 * @private
 * function for removing the selected items
 * @param items type of Array
 * @return void
 *
 */
private function removeSelectedItems(items:Array):void
{
	for each (var o:Object in items)
	{
		selectedDataAC.removeItemAt(selectedDataAC.getItemIndex(o));
	}
}

/**
 *
 * @private
 * function for removing the available items
 * @param items type of Array
 * @return void
 *
 */
private function removeAvailableItems(items:Array):void
{
	for each (var o:Object in items)
	{
		if (originalDataAC.getItemIndex(o) > -1)
			originalDataAC.removeItemAt(originalDataAC.getItemIndex(o));
	}
}

/**
 *
 * @private
 * function for initial call
 * @param event of flex
 * @return void
 *
 */
private function toggleDataListCompCreationCompleteHandler(event:FlexEvent):void
{
	sortSelectedItems();
	sortAvailableItems();
	if (originalDataAC.length > 0 && selectedDataAC.length > 0)
	{
		filterData();
	}
}

/**
 *
 * @protected
 * function for adding an item 
 * @param event of Mouse
 * @return void
 *
 */
protected function addToList_clickHandler(event:MouseEvent):void
{
	//Fix for Bug #11297
	lstOriginalData.setFocus();
	if (selectedDataAC.length < maxSelection)
	{
		var temp:ArrayCollection=new ArrayCollection;
		var tempArr:Array=new Array;
		var i:int=0;
		for (i=0; i < lstOriginalData.selectedItems.length; i++)
		{
			var o:Object=lstOriginalData.selectedItems;
			
			temp.addItem(o[i]);
		}
		tempArr=temp.toArray();
		
		addAll(selectedDataAC, temp);
		sortAvailableItems();
		sortSelectedItems();
		removeAvailableItems(tempArr);
	}
}

/**
 *
 * @protected
 * function for adding an item from the list
 * @param event of Mouse
 * @return void
 *
 */
protected function removeFromList_clickHandler(event:MouseEvent):void
{
	//Fix for Bug #11297
	lstSelectedData.setFocus();
	var temp:ArrayCollection=new ArrayCollection;
	var tempArr:Array=new Array;
	var i:int=0;
	for (i=0; i < lstSelectedData.selectedItems.length; i++)
	{
		var o:Object=lstSelectedData.selectedItems;
		
		temp.addItem(o[i]);
	}
	tempArr=temp.toArray();
	addAll(originalDataAC, temp);
	removeSelectedItems(tempArr);
	if (lstSelectedData.selectedItems.length > 0)
		sortSelectedItems();
	sortAvailableItems();
}
