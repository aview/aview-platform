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
 * File			: QuickNoteComponentHandler.as
 * Module		: QuickNote
 * Developer(s)	: Ajith Kumar R,Sivaram
 * Reviewer(s)	: Remya T
 *
 * QuickNoteComponentHandler.as is used to handle all the major operations (save,load,popin,popout,etc..) in quicknote.
 * 
 */

/**Platform specific imports*/
applicationType::desktop
{
	import edu.amrita.aview.quickNotes.QuickNotePopOutComponent;
}

import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.net.FileFilter;
import flash.text.Font;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.events.DropdownEvent;
import mx.events.ScrollEvent;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;
import mx.controls.Button;
import mx.containers.HBox;
import mx.logging.Log;
import mx.logging.ILogger;


/**
 * Variable for storing the close button clicked status.
 */
public var isCloseButtonPressed:Boolean=false;
/**
 * Variable for preserving the text format to restore data after popin/popout.
 */
public var settingsObject:Object=new Object();
/**
 * Variable for storing the popout button clicked status.
 */
public var isPopOutButtonPressed:Boolean=false;
/**
 * Variable for storing the new-file button clicked status.
 */
public var isNewFilePressed:Boolean=false;
/**
 * Variable for storing the popup created status.
 */
[Bindable]
public var isPopoutCreated:Boolean=false;
/**
 * Variable for storing the icon image for popin button.
 */
[Bindable]
[Embed(source="assets/images/medium_pop_in.png")]
public var popinIcon:Class;
/**
 *   Variable for storing the icon image for maximize button.
 */
[Bindable]
[Embed(source="assets/images/quickNote_maximize.png")]
public var expandIcon:Class;

/**
 * Array for storing names of all installed fonts in the machine.
 */
private var installedFontsArray:Array;

/**
 * Variable for storing the file save progressing status.
 */
private var isFileSavingInProgress:Boolean=false;
/**
 * Variable for storing the collapse 'X' position
 */
[Bindable]
private var collapsePosition:Number;

/**
 * Variable for storing the expand 'X' position
 */
[Bindable]
private var expandPosition:Number;

/**
 * Variable for storing the file name for saving.
 */
[Bindable]
private var savedFileName:String="Untitled.";
/**
 * Variable for storing the timeout id of popout creation.
 */
private var popupCreationTimeout:uint;
/**
 * Button variable for popping in the quicknote component from window to titlewindow.
 */
private var popInBtn:Button=new Button();
/**
 * Variable for storing the scroll position of the richtexteditor.
 */
private var richTxtVerticalScrollPosition:int=-1;
/**
 * Variable for storing the saved text in HTML format.
 */
private var savedHtmlText:String="";
/**
 * Variable for storing the file load status.
 */
private var isFileLoaded:Boolean=false;
/**
 * Variable for storing the status of NewFileSave alert,whether it is active or not.
 */
private var isNewFileSaveAlertActive:Boolean=false;
/**
 * Variable for storing the status of clear-data alert,whether it is active or not.
 */
private var isClearAlertActive:Boolean=false;
/**
 * Variable for storing the status of emptyFileSave alert,whether it is active or not.
 */
private var isEmptyFileSaveAlertActive:Boolean=false;
/**
 * Alert variable for showing various informations related to saving/opening files.
 */
private var infoAlert:Alert;

/**
 * For Log API
 */
private var log:ILogger=Log.getLogger("aview.modules.quickNotes.QuickNoteComponentHandler.as");

/**Platform specific variables*/
applicationType::desktop
{
	/**
	 *  File variable for handling all file operations.
	 */
	private var fileRef:File=new File(); //Bug #10395
	/**
	 *  Popout component for desktop applications
	 */
	public var popOut:QuickNotePopOutComponent;
}
/**
 *
 */
applicationType::web
{
	/**
	 *  FileReference variable for handling all file operations.
	 * 	Since there is no File related class for web application.So we use FileReference instead of File.
	 */
	private var fileRef:FileReference=new FileReference();
}

/**
 * @private
 * Popout event handler for quicknote component
 *
 * @param event accepts any type
 * @return void
 */
private function popOutHandler(event:*):void
{
	popOutWindow();
}

/**
 * @private
 * Minimize event handler for quicknote component
 *
 * @param event accepts any type
 * @return void
 */
private function windowMinimizeHandler(event:*):void
{
	collapsePopOutHandler();
}

/**
 * @private
 * Close event handler for quicknote component
 *
 * @param event accepts any type
 * @return void
 */
private function windowCloseHandler(event:*):void
{
	//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.addFocus();
	closeWindow(event);
}

/**
 * @private
 * CreationComplete handler function for QuickNotePopOutComponent
 * Added all event hanlers & initialize all default values here.
 *
 *
 * @return void
 */
private function init():void
{
	expandPosition=this.x;
	this.addEventListener("miniHandler", windowMinimizeHandler);
	this.addEventListener("popOutHandler", popOutHandler);
	this.addEventListener("clseHandler", windowCloseHandler);
	popInBtn.addEventListener(MouseEvent.CLICK, popOutHandler);
	popInBtn.width=21;
	use namespace mx_internal;
	mx_internal::closeButton.toolTip="Close";
	FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteOpenFlag=true;
	richTxt.fontFamilyCombo.height=22;
	richTxt.fontSizeCombo.height=22;
	richTxt.textArea.setFocus();
	richTxt.fontFamilyCombo.editable=false;
	richTxt.fontSizeCombo.editable=false;
	richTxt.fontFamilyCombo.toolTip="Font family";
	richTxt.fontSizeCombo.toolTip="Font size";
	richTxt.boldButton.toolTip="Bold";
	richTxt.boldButton.selected=false;
	richTxt.italicButton.toolTip="Italic";
	richTxt.underlineButton.toolTip="Underline";
	richTxt.colorPicker.toolTip="Color picker";
	richTxt.alignButtons.toolTip="Align (Left,Center,Right,Justify)";
	richTxt.bulletButton.toolTip="Bullet";
	richTxt.linkTextInput.visible=false;
	
	//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.removeFocus();
}

/**
 * @public
 * Function for setting the x,y cordinate of the quicknote component if it goes beyond the parent application boundry.
 *
 * @param event accepts any type
 * @return void
 */
public function quickNoteMoveHandler(event:*):void
{
	//checking with the x position and width 
	if (this.x < 0)
		this.x=0;
	applicationType::desktop
	{
		setQuickNoteComponentXPosition();
	}
	applicationType::web
	{
		//Guest Login: To avoid null reference issue when the user is a guest.
		//For guest users, stage may not be initialized at this moment.
		if (stage)
		{
			setQuickNoteComponentXPosition();
		}
	}
	//checking with the y position and height 
	if (this.y < 0)
		this.y=0;
	applicationType::desktop
	{
		setQuickNoteComponentYPosition();
	}
	applicationType::web
	{
		//Guest Login: To avoid null reference issue when the user is a guest.
		//For guest users, stage may not be initialized at this moment.
		if (stage)
		{
			setQuickNoteComponentYPosition();
		}
	}
}
/**
 * @private
 * Function for setting the X position of the quicknote component.
 *
 *
 * @return void
 */
private function setQuickNoteComponentXPosition():void
{
	if ((this.x + this.width) > FlexGlobals.topLevelApplication.mainApp.stage.stageWidth)
	{
		var val:Number=0;
		val=(this.x + this.width) - FlexGlobals.topLevelApplication.mainApp.stage.stageWidth;
		this.x=this.x - val;
	}
}
/**
 * @private
 * Function for setting the Y position of the quicknote component.
 *
 *
 * @return void
 */
private function setQuickNoteComponentYPosition():void
{
	if ((this.y + this.height) > FlexGlobals.topLevelApplication.mainApp.stage.stageHeight)
	{
		var val:Number=0;
		val=(this.y + this.height) - FlexGlobals.topLevelApplication.mainApp.stage.stageHeight;
		this.y=this.y - val;
	}
}

/**
 * @private
 * Resize event handler for quicknote component
 *
 *
 * @return void
 */
private function resizeHandler():void
{
	if (richTxt)
	{
		richTxt.width=quickNoteVBox.width;
		richTxt.textArea.width=richTxt.width - 2;
	}
}

/**
 * @private
 * Function for saving the contents entered in the quicknote.
 *
 *
 * @return void
 */
private function save():void
{
	if (StringUtil.trim(richTxt.text).length > 0 && !isTextChanged())
	{
		applicationType::web
		{
			//Modification for save a file in quick note 
			saveData();
		}
		applicationType::desktop
		{
			//PNCR: the string "Untitled." seems using in many plases, create a constant for that. 
			if (savedFileName == "Untitled.")
			{
				saveData();
			}
			else
			{
				//File and NativePath are not available for web.
				var file:File=new File(fileRef.nativePath);
				var fs:FileStream=new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeUTFBytes(richTxt.htmlText);
				fs.close();
			}
		}
		if (isNewFilePressed)
		{
			resetForNewFile();
		}
		isFileSavingInProgress=true;
	}
	else
	{
		if (StringUtil.trim(richTxt.text).length == 0 && savedFileName == "Untitled.")
		{
			isEmptyFileSaveAlertActive=true;
			infoAlert=Alert.show("Do you want to save the quick note without any content?", "Confirmation", Alert.YES | Alert.NO, quickNoteVBox, saveEmptyFileHandler, null, 1);
			infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
		}
		if (isNewFilePressed)
		{
			resetForNewFile();
		}
	}
}

/**
 * @private
 * Confirmation alert handler for saving empty file.
 *
 * @param event of type CloseEvent
 * @return void
 */
private function saveEmptyFileHandler(event:CloseEvent):void
{
	isEmptyFileSaveAlertActive=false;
	if (event.detail == Alert.YES)
	{
		saveData();
	}
}

/**
 * @private
 * Function for saving the contents entered in the quicknote.
 *
 *
 * @return void
 */
private function saveData():void
{
	fileRef.addEventListener(Event.COMPLETE, completeHandlerForAppClosing);
	fileRef.addEventListener(Event.CANCEL, completeHandlerForAppClosing);
	fileRef.addEventListener(Event.CLOSE, completeHandlerForAppClosing);
	applicationType::web
	{
		//Modification for save a file in quick note
		if (savedFileName == "Untitled.")
		{
			fileRef.save(richTxt.htmlText, "myFile.aqn");
		}
		else
		{
			fileRef.save(richTxt.htmlText, savedFileName);
		}
	}
	applicationType::desktop
	{
		fileRef.save(richTxt.htmlText, "myFile.aqn");
	}
	isFileSavingInProgress=true;
}

/**
 * @public
 * Function for closing quicknote after saving.
 *
 * @param event of type Event
 * @return void
 */
public function completeHandlerForAppClosing(event:Event):void
{
	try
	{
		savedFileName=event.target.name.toString();
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in completeHandlerForAppClosing method"+ e.getStackTrace());
	}
	if (event.type == "cancel")
	{
		savedHtmlText="";
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.removeFocus();
	}
	fileRef.removeEventListener(Event.COMPLETE, completeHandlerForAppClosing);
	fileRef.removeEventListener(Event.CANCEL, completeHandlerForAppClosing);
	fileRef.removeEventListener(Event.CLOSE, completeHandlerForAppClosing);
	isFileSavingInProgress=false;
	if (isCloseButtonPressed && event.type != "cancel")
	{
		PopUpManager.removePopUp(this);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote=null;
	}
	if (isNewFilePressed && event.type != "cancel")
	{
		resetForNewFile();
	}
}

/**
 * @private
 * Function for opening a selected quicknote file.
 *
 * @return void
 */
private function read():void
{
	var textTypes:FileFilter=new FileFilter("QuickNote Files (*.aqn)", "*.aqn");
	fileRef.addEventListener(Event.SELECT, selectHandler);
	fileRef.addEventListener(Event.COMPLETE, completeHandler);
	fileRef.browse(new Array(textTypes));
}

/**
 * @public
 * SELECT handler function for file open.
 *
 * @param event of type Event
 * @return void
 */
public function selectHandler(event:Event):void
{
	applicationType::web
	{
		//'event.target.extension' is not supported in web.So we used 'event.target.type'
		// returns file extension with dot (.) infront of extension (Eg:.aqn)
		var fileExtension:String=event.target.type.substring((event.target.type.lastIndexOf(".") + 1), event.target.type.length);
		if (fileExtension == "aqn")
		{
			fileRef.load();
		}
		else
		{
			infoAlert=Alert.show("Please choose an 'aqn' file.", "INFO", 0, quickNoteVBox);
			infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
		}
	}
	applicationType::desktop
	{
		if (event.target.extension == "aqn")
		{
			fileRef.load();
		}
		else
		{
			infoAlert=Alert.show("Please choose an 'aqn' file.", "INFO", 0, quickNoteVBox);
			infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
		}
	}
}

/**
 * @public
 * COMPLETE handler function for file open.
 *
 * @param event of type Event
 * @return void
 */
public function completeHandler(event:Event):void
{
	isFileLoaded=true;
	fileRef.removeEventListener(Event.SELECT, selectHandler);
	fileRef.removeEventListener(Event.COMPLETE, completeHandler);
	savedFileName=event.target.name.toString();
	savedHtmlText=richTxt.htmlText=fileRef.data.toString();
}

/**
 * @private
 * Function for clearing the contents in quicknote
 *
 *
 * @return void
 */
private function clear():void
{
	if (StringUtil.trim(richTxt.text).length > 0)
	{
		isClearAlertActive=true;
		infoAlert=Alert.show("Are you sure you want to clear the quick note?", "Confirmation", Alert.YES | Alert.NO, quickNoteVBox, clearConfirmationHandler, null, 1);
		infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
	}
}

/**
 * @private
 * Confirmation alert handler for clear option.
 *
 * @param event of type CloseEvent
 * @return void
 */
private function clearConfirmationHandler(event:CloseEvent):void
{
	isClearAlertActive=false;
	if (event.detail == Alert.YES)
	{
		richTxt.htmlText="";
	}
}

/**
 * @private
 * Close event handler for quicknote component
 *
 * @param event accepts any type
 * @return void
 */
private function closeHandler(event:*):void
{
	event.preventDefault();
	if (savedHtmlText != richTxt.htmlText)
	{
		if (isFileSavingInProgress)
		{ 
			// To check whether the popout is collapsed.
			//if collapsed, it will expand and show the alert to save or not
			if (this.width == 250)
			{
				this.collapseButton.setStyle("icon", this.collapseIcon);
				this.collapseButton.toolTip="Collapse";
				this.height=500;
				this.width=600;
			}
			infoAlert=Alert.show("Do you want to save the quick note?", "Confirmation", Alert.YES | Alert.NO | Alert.CANCEL, quickNoteVBox, saveConfirmationHandler, null, 1);
			infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
		}
		else
		{
			//bug number : 15034
			//bug fixed by:GTM 
			//File shaving is not in the process mean time the richeditor content has been modified 
			//alert the user to take the decesion to save or quit
			infoAlert=Alert.show("Do you want to save the quick note?", "Confirmation", Alert.YES | Alert.NO | Alert.CANCEL , quickNoteVBox, saveConfirmationHandler, null, 1);
			infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
		}
	}
	else
	{
		isCloseButtonPressed=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteIcon_UnClicked;
		try
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteOpenFlag=false;
		}
		catch (e:Error)
		{
			if(Log.isError()) log.error("Error in closeHandler method"+ e.getStackTrace());
		}
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quicknoteMenuContainer.backgroundFill = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.normalBackground;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lblQuickNote.setStyle("color",0x12548E);
		PopUpManager.removePopUp(this);
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote=null;
	}
}

/**
 * @private
 * Confirmation alert handler for save option.
 *
 * @param event of type CloseEvent
 * @return void
 */
private function saveConfirmationHandler(event:CloseEvent):void
{
	if (event.detail == Alert.CANCEL)
	{
		//creating bug since viewer3DSWC not there
		//modified by : GTM
		//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.removeFocus();
	}
	else
	{
		isCloseButtonPressed=true;
		FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteIcon_UnClicked;
		try
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteOpenFlag=false;
		}
		catch (e:Error)
		{
			if(Log.isError()) log.error("Error in saveConfirmationHandler method"+ e.getStackTrace());
		}
		if (event.detail == Alert.YES)
		{
			savedHtmlText=richTxt.htmlText;
			applicationType::web
			{
				//Modification for save a file in quick note
				saveData();
			}
			applicationType::desktop
			{
				if (savedFileName == "Untitled.")
				{
					saveData();
				}
				else
				{
					//File and NativePath are not available for web.
					var file:File=new File(fileRef.nativePath);
					var fs:FileStream=new FileStream();
					fs.open(file, FileMode.WRITE);
					fs.writeUTFBytes(richTxt.htmlText);
					fs.close();
					PopUpManager.removePopUp(this);
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quicknoteMenuContainer.backgroundFill = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.normalBackground;
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lblQuickNote.setStyle("color",0x12548E);
					FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote=null;
				}
			}
		}
		else if (event.detail == Alert.NO)
		{
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quicknoteMenuContainer.backgroundFill = FlexGlobals.topLevelApplication.mainApp.mainContainerComp.normalBackground;
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.lblQuickNote.setStyle("color",0x12548E);
			PopUpManager.removePopUp(this);
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote=null;
		}
	}
}

/**
 * @private
 * Function for getting all the installed font names.
 *
 *
 * @return void
 */
private function findAllFonts():void
{
	installedFontsArray=Font.enumerateFonts(true);
}

/**
 * @private
 * CreationComplete event handler for quicknote component
 *
 * @return void
 */
private function creationCompleteHandler():void
{
	richTxt.textArea.addEventListener(ScrollEvent.SCROLL, scrollHandler);
	// The text editor toolbar is removed from the bottom and added to the top of the editor 
	richTxt.toolbar.parent.removeChild(richTxt.toolbar);
	var hbox:HBox=new HBox();
	hbox.percentWidth=100;
	hbox.setStyle('paddingLeft', 5);
	hbox.setStyle('paddingTop', 10);
	hbox.setStyle('paddingRight', 5);
	hbox.setStyle('paddingBottom', 5);
	hbox.addChild(controlBoxContainer);
	hbox.addChild(richTxt.toolbar);
	richTxt.addChildAt(hbox, 0);
	richTxt.toolbar.removeChild(richTxt.linkTextInput);
	findAllFonts();
	var checkForCourier:Boolean=false;
	for (var i:int=0; i < installedFontsArray.length; i++)
	{
		if (installedFontsArray[i].fontName == "Courier")
			checkForCourier=true;
	}
	var fontArray:Array;
	if (checkForCourier)
		fontArray=new Array("_sans", "_serif", "_typewriter", "Arial", "Courier", "Courier New", "Geneva", "Georgia", "Helvetica", "Times New Roman", "Verdana");
	else
		fontArray=new Array("_sans", "_serif", "_typewriter", "Arial", "Courier New", "Geneva", "Georgia", "Helvetica", "Times New Roman", "Verdana");
	richTxt.fontFamilyCombo.dataProvider=fontArray;
	richTxt.fontFamilyCombo.selectedIndex=3;
}

/**
 * @public
 * This function handles the QuickNote pop-in and pop-out functionality.
 *
 *
 * @return void
 */
public function popOutWindow():void
{
	applicationType::desktop{
		// This handles the pop-out function 
		isPopOutButtonPressed=true;
		if (!isPopoutCreated){
			
			FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteIcon=FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNoteIcon_Clicked;
			popOut=new QuickNotePopOutComponent();
			restoreData();
			this.removeChild(quickNoteVBox);
			popOut.addChild(quickNoteVBox);
			popOut.open(true);
			this.visible=false;
			isPopoutCreated=true;
			popInBtn.setStyle("icon", popinIcon);
			popupCreationTimeout=setTimeout(setEditorSettings, 200);
			popInBtn.toolTip="Pop-in";
			richTxt.toolbar.addChild(popInBtn);
		} else{
			// This handles the pop-in function 
			if (popOut){
				//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.removeFocus();
				isPopoutCreated=false;
				restoreData();
				popOut.removeChild(quickNoteVBox);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote.addChild(quickNoteVBox);
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote.visible=true;
				FlexGlobals.topLevelApplication.mainApp.mainContainerComp.quickNote.quickNoteVBox.width=600;
				popOut.nativeWindow.close();
				popInBtn.setStyle("icon", popoutIcon);
				popupCreationTimeout=setTimeout(setEditorSettings, 200);
				popInBtn.toolTip="Pop-out";
				richTxt.toolbar.removeChild(popInBtn);
				
				if (isNewFileSaveAlertActive){
					newFile();
				}
				if (isClearAlertActive){
					clear();
				}
				if (isEmptyFileSaveAlertActive){
					infoAlert=Alert.show("Do you want to save the quick note without any content?", "Confirmation", Alert.YES | Alert.NO, quickNoteVBox, saveEmptyFileHandler, null, 1);
					infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
				}
			}
		}
	}
}

/**
 * @private
 * This function is to restore data in the quick note preserving the text format.
 *
 *
 * @return void
 */
private function restoreData():void
{
	settingsObject.htmlText=richTxt.textArea.htmlText;
	settingsObject.fontFamily=richTxt.fontFamilyCombo.selectedIndex;
	settingsObject.fontSize=richTxt.fontSizeCombo.selectedIndex;
	settingsObject.color=richTxt.colorPicker.selectedIndex;
}

/**
 * @public
 * This function handles the collapse and expand functionality.
 *
 *
 * @return void
 */
public function collapsePopOutHandler():void
{
	var val:Number;
	if (this.width == 250)
	{
		//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.removeFocus();
		this.collapseButton.setStyle("icon", this.collapseIcon);
		this.collapseButton.toolTip="Collapse";
		this.height=500;
		this.width=600;
		this.x=collapsePosition;
	}
	else
	{
		//FlexGlobals.topLevelApplication.mainApp.mainContainerComp.classroomComp.viewer3DComp.viewer3DSWC.addFocus();
		collapsePosition=this.x;
		this.collapseButton.setStyle("icon", expandIcon);
		this.collapseButton.toolTip="Expand";
		this.height=33;
		this.width=250;
		this.x=collapsePosition + 350;
	}
	
	val=0;
	val=(this.y + this.height) - FlexGlobals.topLevelApplication.mainApp.stage.stageHeight;
	this.y=(this.y - val) - 5;
	
	val=0;
	val=(this.x + this.width) - FlexGlobals.topLevelApplication.mainApp.stage.stageWidth;
	this.x=(this.x - val) - 20;
}

/**
 * @public
 * Close event handler for quicknote component
 *
 * @param event accepts all type
 * @return void
 */
public function closeWindow(event:*):void
{
	closeHandler(event);
}

/**
 * @public
 * Function for applying the saved text format to the richtexteditor (after pop-out or pop-in operations)
 *
 *
 * @return void
 */
public function setEditorSettings():void
{
	clearTimeout(popupCreationTimeout);
	richTxt.textArea.htmlText=settingsObject.htmlText;
	richTxt.fontFamilyCombo.selectedIndex=settingsObject.fontFamily;
	richTxt.fontFamilyCombo.dispatchEvent(new DropdownEvent(DropdownEvent.CLOSE));
	richTxt.fontSizeCombo.selectedIndex=settingsObject.fontSize;
	richTxt.fontSizeCombo.dispatchEvent(new DropdownEvent(DropdownEvent.CLOSE));
	richTxt.colorPicker.selectedIndex=settingsObject.color;
	richTxt.colorPicker.dispatchEvent(new DropdownEvent(DropdownEvent.CLOSE));
	richTxt.textArea.setFocus();
	applicationType::desktop{
		if (isPopoutCreated && popOut) //issue#10741
		{
			popOut.width=popOut.width + 1;
			popOut.height=popOut.height + 1;
		}
	}
}

/**
 * @private
 * Function to find any changes happened to the text after saving.
 *
 *
 * @return Boolean
 */
private function isTextChanged():Boolean
{
	var isTextSame:Boolean=false;
	if (savedHtmlText == richTxt.htmlText)
	{
		isTextSame=true;
	}
	else
	{
		isTextSame=false;
		savedHtmlText=richTxt.htmlText;
	}
	
	return isTextSame;
}

/**
 * @public
 * Function for invoking the save function before creating new file.
 *
 *
 * @return void
 */
public function newFile():void
{
	if (savedFileName != "Untitled." || (savedFileName == "Untitled." && StringUtil.trim(richTxt.text).length > 0))
	{
		if (savedHtmlText != richTxt.htmlText)
		{
			isNewFileSaveAlertActive=true;
			infoAlert=Alert.show("Do you want to save the quick note?", "Confirmation", Alert.YES | Alert.NO | Alert.CANCEL, quickNoteVBox, saveNewFileHandler, null, 1);
			infoAlert.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener, true);
		}
		else
		{
			resetForNewFile();
		}
	}
}

/**
 * @private
 * Confirmation alert handler for save new file.
 *
 * @param event of type CloseEvent
 * @return void
 */

private function saveNewFileHandler(event:CloseEvent):void
{
	isNewFileSaveAlertActive=false;
	if (event.detail == Alert.YES)
	{
		isNewFilePressed=true;
		save();
	}
	else if (event.detail == Alert.NO)
	{
		resetForNewFile();
	}
	richTxt.textArea.setFocus();
}

/**
 * @public
 * Function for clearing the previous contents before creating new file.
 *
 *
 * @return void
 */

public function resetForNewFile():void
{
	richTxt.htmlText="";
	savedHtmlText="";
	savedFileName="Untitled.";
	isNewFilePressed=false;
	richTxt.textArea.setFocus();
}

/**
 * @public
 * This function is to handle the position of the quick note window while resizing the main application.
 *
 *
 * @return void
 */
public function setWidowPosition():void
{
	var currentLeft:Number=Number(this.x);
	var currentTop:Number=Number(this.y);
	try
	{
		if (this.parent.width < (this.x + this.width))
		{
			this.x=this.parent.width - this.width;
		}
		else if (this.x < 0)
		{
			this.x=0;
		}
		if (this.parent.height < (this.y + this.height))
		{
			this.y=this.parent.height - this.height;
		}
		else if (this.y < 0)
		{
			this.y=0;
		}
	}
	catch (e:Error)
	{
		if(Log.isError()) log.error("Error in setWidowPosition method"+ e.getStackTrace());
	}
}

/**
 * @private
 * ValueCommit event handler function of richtexeditor (for applying the scroll position).
 *
 *
 * @return void
 */
private function valueCommitHandler():void
{
	if (isFileLoaded)
	{
		isFileLoaded=false;
		richTxt.textArea.verticalScrollPosition=0;
	}
	else
	{
		if (richTxtVerticalScrollPosition != -1)
			richTxt.textArea.verticalScrollPosition=richTxtVerticalScrollPosition;
	}
	richTxtVerticalScrollPosition=richTxt.textArea.verticalScrollPosition;
}

/**
 * @private
 * Scroll event handler function of richtexeditor (for storing the scroll position to a variable).
 *
 * @param event of type Event
 * @return void
 */
private function scrollHandler(event:Event):void
{
	if (!isPopOutButtonPressed)
		richTxtVerticalScrollPosition=richTxt.textArea.verticalScrollPosition;
	else
		isPopOutButtonPressed=false;
}

/**
 * @public
 * MouseDown event handler function of INFO alert.
 *
 * @param event of type MouseEvent
 * @return void
 */
public function mouseDownListener(event:MouseEvent):void
{
	event.stopImmediatePropagation();
}
