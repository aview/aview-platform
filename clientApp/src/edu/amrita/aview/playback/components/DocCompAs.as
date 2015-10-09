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
 * File			: DocCompAs.as
 * Module		: PlayBack
 * Developer(s)	: Anu, Haridas
 * Reviewer(s)  : Thirumalai murugan
 * Description:This file used for document play back .It handling the two types of file like
 * animated and non animated file.Also thumbnial view also supported
 */

import edu.amrita.aview.core.documentSharing.components.thumbnails.CustomThumbnailEvents.OnSlideChangedEvent;
import edu.amrita.aview.playback.DocumentPlayer;
import edu.amrita.aview.playback.events.AviewPlayerEvent;

import flash.events.Event;

import mx.core.FlexGlobals;
/**
 * For handling the documnet play back
 */
public var documentPlayer:DocumentPlayer=new DocumentPlayer();
[Bindable]
/**
 * Current document's height
 */
private var docHeight:Number
[Bindable]
/**
 * Current document's Width
 */
private var docWidth:Number
/**
 * @private
 * Setting the UI reference to DocumentPlayer class
 * 
 * @return void
 */
private function init():void
{
	
	documentPlayer.setUiReference(p2fLoader,docCanvas,ispringLoader,ispringCanvas,baseContainer,docHeight,docWidth);
	documentPlayer.addEventListener("OnSlideChangedEvent",onslideChanged);
	setDocLoader()
}
/**
 * @private
 * Function invoked while user change document page through
 * slide panel
 * @param event for OnSlideChangedEvent
 * @return void
 */
private function onslideChanged(ev:OnSlideChangedEvent):void
{
	this.dispatchEvent(new OnSlideChangedEvent(ev.index));
}

//VVCR: Can be reomved if not using.
private function closeButtonVisibility():void
{/*
	if(FlexGlobals.topLevelApplication.mainContainerComp.isPlayback)
		slideWndw.showCloseButton = true;*/
}
/**
 * @public
 * Function invoked while user colse the slide panel
 * Here we dispatching a event AviewPlayerEvent.SLIDE_PANNEL_CLOSSED
 * 
 * @return void
 */

public function closeSlidePanel():void
{
//	this.removeChild(slideWndw);
	baseContainer.percentHeight=100;  
	this.dispatchEvent(new AviewPlayerEvent(AviewPlayerEvent.SLIDE_PANNEL_CLOSSED));
	//(uploadFile,fileExtention,currentParentFolder+"/"+uploadFile));	 	      		 	
}
/**
 * @private
 * Function for handling the resolution of Document play back window
 * 
 * @return void
 */
private function setDocLoader():void
{
	var tempWidth:Number;
	
	docHeight=baseContainer.height-10;				 
	tempWidth=(docHeight / 3) * 4;
	if (tempWidth >= baseContainer.width)
	{
		docWidth=baseContainer.width-10;
		docHeight=(docHeight/ 4) * 3;
	}
	else
	{
		docWidth=tempWidth;
	}	
}
//GTMCR:: change the function name
/**
 * @public
 * Function invoked while user Click on slide panel item.
 * Here we dispatching a event  AviewPlayerEvent.SlideSlected
 * @param event for Event
 * @return void
 */
public function slidelist_itemClickHandler(event:Event):void
{
	//documentPlayer.setContext(event.currentTarget.selectedItem.ctime)
	var evnt:AviewPlayerEvent=new AviewPlayerEvent(AviewPlayerEvent.SlideSlected);
	evnt.time=event.currentTarget.selectedItem.ctime
	this.dispatchEvent(evnt);
	
}