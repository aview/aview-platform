////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: AutoComplete.as
 * Module		: common
 * Developer(s)	: Vijaykumar R 
 * Reviewer(s)	: Sivaram SK,Vishnupreethi K
 *
 * This is a custom component for populating the
 * data from the database based text which entered in the text component
 */

package edu.amrita.aview.common.components.autoComplete
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import edu.amrita.aview.audit.AuditContext;
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.SandboxMouseEvent;
	
	import spark.components.Group;
	import spark.components.List;
	import spark.components.PopUpAnchor;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TextOperationEvent;
	
	[Event(name="select", type="edu.amrita.aview.common.components.autoComplete.CustomEvent")]
	
	[Event(name="enter", type="mx.events.FlexEvent")]
	
	[Event(name="change", type="spark.events.TextOperationEvent")]
	
	/**
	 * Dispatched if text entered is not in the dataprovider
	 */
	[Event(name="notInList", type="flash.events.Event")]
	/**
	 * VPCR: Add class description */
	 
	public class AutoComplete extends SkinnableComponent
	{
		/**
		 * @public
		 * constructor
		 */
		public function AutoComplete()
		{
			super();
			this.mouseEnabled=true;
			this.setStyle("skinClass", Class(AutoCompleteSkin));
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
			setupCollection();
		}
		/**
		 * SKCR: Add comments
		 * */
		private var focusLostCount:Number=0;
		public var maxRows:Number=6;
		public var minChars:Number=1;
		public var prefixOnly:Boolean=false;
		public var requireSelection:Boolean=true;
		public var forceOpen:Boolean=false;
		public var returnField:String;
		public var sortFunction:Function=defaultSortFunction;
		
		[SkinPart(required="true", type="spark.components.Group")]
		public var dropDown:Group;
		[SkinPart(required="true", type="spark.components.PopUpAnchor")]
		public var popUp:PopUpAnchor;
		[SkinPart(required="true", type="spark.components.List")]
		public var list:List;
		[SkinPart(required="true", type="spark.components.TextInput")]
		public var inputTxt:TextInput;
		
		private var _text:String="";
		private var _labelField:String;
		private var _labelFunction:Function;
		private var _selectedIndex:int=-1;
		private var _selectedItem:Object;
		/**
		 * Creating an array collection variable
		 * **/
		private var collection:ListCollectionView=new ArrayCollection();
		
		/**
		 * @protected
		 * @param partName type String
		 * @param instance type Object
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance)
			
			if (instance == inputTxt)
			{
				//Adding the various event listeners to the textbox components
				inputTxt.addEventListener(FocusEvent.FOCUS_OUT, _focusOutHandler)
				inputTxt.addEventListener(FocusEvent.FOCUS_IN, _focusInHandler)
				inputTxt.addEventListener(MouseEvent.CLICK, _focusInHandler)
				inputTxt.addEventListener(TextOperationEvent.CHANGE, onChange);
				inputTxt.addEventListener("keyDown", onKeyDown);
				inputTxt.addEventListener(FlexEvent.ENTER, enter)
				inputTxt.text=_text;
			}
			if (instance == list)
			{
				//assigning the arraycollection variable to the list component as a dataporvider
				list.dataProvider=collection;
				//specifing the labelfield to the list component, this will show in the component
				list.labelField=labelField;
				//specifing the label function to the list component, this will invoke a method.
				list.labelFunction=labelFunction
				//Adding the event listener to the textbox components	
				list.addEventListener(FlexEvent.CREATION_COMPLETE, addClickListener)
				list.focusEnabled=false;
				list.requireSelection=requireSelection
			}
			if (instance == dropDown)
			{
				//Adding the various event listeners to the dropdown components
				dropDown.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, mouseOutsideHandler);
				dropDown.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, mouseOutsideHandler);
				dropDown.addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, mouseOutsideHandler);
				dropDown.addEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE, mouseOutsideHandler);
			}
		}
		/**
		 * SKCR: Add comments */
		/**
		 *  @private
		 */
		private function setupCollection():void
		{
			collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChange)
			collection.filterFunction=filterFunction;
			var customSort:Sort=new Sort();
			customSort.compareFunction=sortFunction
			collection.sort=customSort
		}
		
		/**
		 * @public
		 * setter function for the dataprovider
		 * @param value type Object
		 * @return void
		 */
		public function set dataProvider(value:Object):void
		{
			/**
			 * SKCR: Add comments */
			if (value is Array)
				collection=new ArrayCollection(value as Array);
			else if (value is ListCollectionView)
			{
				collection=value as ListCollectionView;
			}
			setupCollection();
			
			if (list)
				list.dataProvider=collection;
			filterData();
		}
		
		/**
		 * @public
		 * getter function for the dataprovider
		 * @return Object
		 */
		public function get dataProvider():Object
		{
			return collection;
		}
		
		/**
		 * @private
		 * @param event need to pass the collection event
		 * @return void
		 */
		private function collectionChange(event:CollectionEvent):void
		{
			/**
			 * SKCR: Add comments */
			if (event.kind == CollectionEventKind.RESET || event.kind == CollectionEventKind.ADD)
				filterData();
		}
		
		/**
		 * @public
		 * setter function for the text
		 * @param text type String
		 * @return void
		 */
		public function set text(text:String):void
		{
			_text=text;
			if (inputTxt)
				inputTxt.text=text;
		}
		
		/**
		 * @public
		 * getter function for the text
		 * @return string
		 */
		public function get text():String
		{
			return _text;
		}
		
		/**
		 * @public
		 * setter function for the label field
		 * @param field type String
		 * @return void
		 */
		public function set labelField(field:String):void
		{
			_labelField=field;
			if (list)
				list.labelField=field
		}
		
		/**
		 * @public
		 * getter function for the label field
		 * @return string
		 */
		public function get labelField():String
		{
			return _labelField
		}
		
		/**
		 * @public
		 * setter function for the label function
		 * @param func type Function
		 * @return void
		 */
		public function set labelFunction(func:Function):void
		{
			_labelFunction=func;
			if (list)
				list.labelFunction=func
		}
		
		/**
		 * @public
		 * getter function for the label function
		 * @return Function
		 */
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		/**
		 * @public
		 * getter function for the selected item
		 * @return Object
		 */
		public function get selectedItem():Object
		{
			return _selectedItem;
		}
		
		/**
		 * @public
		 * setter function for the selected item
		 * @param item type Object
		 * @return void
		 */
		public function set selectedItem(item:Object):void
		{
			_selectedItem=item;
			text=returnFunction(item);
		}
		
		/**
		 * @public
		 * getter function for the selected index
		 * @return integer
		 */
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		/**
		 * @public
		 * getter function for the selected index
		 * @param index type Integer
		 * @return void
		 */
		public function set selectedIndex(index:int):void
		{
			_selectedIndex=index;
			list.selectedIndex=_selectedIndex;
		}
		
		/**
		 * @private
		 * to handle the change events
		 * @param event type TextOperationEvent
		 * @return void
		 */
		private function onChange(event:TextOperationEvent):void
		{
			_text=inputTxt.text;
			filterData()
			
			if (text.length >= minChars)
				filterData();
			
			dispatchEvent(event);
		}
		
		/**
		 * @public
		 * for filter the data based on the text entered in the text field
		 * @return void
		 */
		public function filterData():void
		{
			/**
			 * SKCR: Add comments */
			if (!this.focusManager || this.focusManager.getFocus() != inputTxt)
				return;
			
			if (!popUp)
				return;
			
			collection.refresh();
			
			if ((text == "" || collection.length == 0) && !forceOpen)
			{
				popUp.displayPopUp=false
			}
			else
			{
				popUp.displayPopUp=true
				if (requireSelection)
					list.selectedIndex=0;
				else
					list.selectedIndex=-1;
				list.dataGroup.verticalScrollPosition=0
				list.dataGroup.horizontalScrollPosition=0
				list.height=Math.min(maxRows, collection.length) * 22 + 2;
				list.validateNow()
				popUp.width=inputTxt.width
			}
		}
		
		/**
		 * @public
		 * default filter function
		 * @param item type Object
		 * @return Boolean
		 */
		public function filterFunction(item:Object):Boolean
		{
			/**
			 * SKCR: Add comments */
			var label:String=itemToLabel(item).toLowerCase();
			if (prefixOnly)
			{
				// AKCR: use a conditional operator, perhaps
				// return (label.search(text.toLowerCase()) == 0) ? true : false
				if (label.search(text.toLowerCase()) == 0)
					return true;
				else
					return false;
			}
			// infix mode
			else
			{
				if (label.search(text.toLowerCase()) != -1)
					return true;
			}
			return false;
		}
		
		/**
		 * @public
		 * to show the label
		 * @param item type Object
		 * @return String
		 */
		public function itemToLabel(item:Object):String
		{
			if (item == null)
				return "";
			//Reverted the previous commit and check if the label function equals to null
			if (labelFunction != null)
				return labelFunction(item);
			else if (labelField && item[labelField])
				return item[labelField];
			else
				return item.toString();
		}
		
		/**
		 * @private
		 * @param item type Object
		 * @return String
		 */
		private function returnFunction(item:Object):String
		{
			if (item == null)
				return "";
			
			if (returnField)
				return item[returnField];
			else
				return itemToLabel(item);
		}
		
		/**
		 * @public
		 * default sorting - alphabetically ascending
		 * @param item1 type Object
		 * @param item2 type Object
		 * @param fields type Array Default value Null
		 * @return Integer
		 */
		public function defaultSortFunction(item1:Object, item2:Object, fields:Array=null):int
		{
			var label1:String=itemToLabel(item1);
			var label2:String=itemToLabel(item2);
			if (label1 < label2)
				return -1;
			else if (label1 == label2)
				return 0;
			else
				return 1;
		
		}
		
		/**
		 * @private
		 * @param event type KeyboardEvent
		 * @return void
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			/**
			 * SKCR: Add comments */
			if (popUp.displayPopUp)
			{
				switch (event.keyCode)
				{
					case Keyboard.UP:
					case Keyboard.DOWN:
					case Keyboard.END:
					case Keyboard.HOME:
					case Keyboard.PAGE_UP:
					case Keyboard.PAGE_DOWN:
						inputTxt.selectRange(text.length, text.length)
						list.dispatchEvent(event)
						break;
					case Keyboard.ENTER:
						acceptCompletion();
						break;
					case Keyboard.TAB:
						if (requireSelection)
							acceptCompletion();
						else
							popUp.displayPopUp=false
						break;
					case Keyboard.ESCAPE:
						popUp.displayPopUp=false
						break;
				}
				
			}
		}
		
		/**
		 * @private
		 * @param event type FlexEvent
		 * @return void
		 */
		private function enter(event:FlexEvent):void
		{
			if (popUp.displayPopUp && list.selectedIndex > -1)
				return;
			dispatchEvent(event)
		}
		
		/**
		 * @private
		 * this is a workaround to reset the Mouse cursor
		 * @param event type MouseEvent
		 * @return void
		 */
		private function onMouseOut(event:MouseEvent):void
		{
			Mouse.cursor=MouseCursor.AUTO;
		}
		/**
		 * SKCR: Add comments */
		/**
		 * @public
		 * @return void
		 */
		public function acceptCompletion():void
		{
			if (list.selectedIndex >= 0 && collection.length > 0)
			{
				
				_selectedIndex=list.selectedIndex
				_selectedItem=collection.getItemAt(_selectedIndex)
				
				text=returnFunction(_selectedItem)
				
				inputTxt.selectRange(inputTxt.text.length, inputTxt.text.length)
				
				var e:CustomEvent=new CustomEvent("select", _selectedItem)
				dispatchEvent(e)
				
			}
			else
			{
				_selectedIndex=list.selectedIndex=-1
				_selectedItem=null
			}
			
			popUp.displayPopUp=false
		
		}
		
		/**
		 * @private
		 * for handling the focusIn handler
		 * @param event type Event
		 * @return void
		 */
		private function _focusInHandler(event:Event):void
		{
			if (forceOpen)
			{
				filterData();
			}
		}
		
		/**
		 * @private
		 * for handling the focusOut handler
		 * @param event type FocusEvent
		 * @return void
		 */
		private function _focusOutHandler(event:FocusEvent):void
		{
			if (inputTxt.text != "")
			{
				acceptCompletion();
			}
			close(event)
			
			if (collection.length == 0)
			{
				_selectedIndex=-1;
				_selectedItem=null;
			}
		}
		
		/**
		 * @private
		 * for handling the Mouse out handler
		 * @param event type Event
		 * @return void
		 */
		private function mouseOutsideHandler(event:Event):void
		{
			if (event is FlexMouseEvent)
			{
				var e:FlexMouseEvent=event as FlexMouseEvent;
				if (inputTxt.hitTestPoint(e.stageX, e.stageY))
					return;
			}
			close(event);
		}
		
		/**
		 * @public
		 * for handling the Close event
		 * @param event type Event
		 * @return void
		 */
		public function close(event:Event):void
		{
			if (dataProvider.length == 0 && inputTxt.text != "" && inputTxt.text != null && focusLostCount == 0)
			{
				_selectedIndex=-1;
				_selectedItem=null;
				//inputTxt.text = "";
				dispatchEvent(new Event("notInList"));
			}
			popUp.displayPopUp=false;
		}
		
		/**
		 * @private
		 * for handling the click event
		 * @param event type Event
		 * @return void
		 */
		private function addClickListener(event:Event):void
		{
			list.dataGroup.addEventListener(MouseEvent.CLICK, listItemClick)
		}
		
		/**
		 * @private
		 * for handling the item selection handler
		 * @param event type MouseEvent
		 * @return void
		 */
		private function listItemClick(event:MouseEvent):void
		{
			acceptCompletion();
			event.stopPropagation();
		}
		
		/**
		 * @public
		 * @param value type Boolean
		 * @return void
		 */
		override public function set enabled(value:Boolean):void
		{
			super.enabled=value;
			if (inputTxt)
				inputTxt.enabled=value;
		}
	
	}

}
