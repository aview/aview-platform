// ActionScript file
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
 File		    : SnapShotComponentHandler.as
 Module		    : Biometric
 Developer(s)   : Ajith
 Reviewer(s)	: Ramesh Guntha
 
 */
//VGCR:-Add function description
//VGCR:-Variable Description
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.media.Camera;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.utils.ByteArray;
import flash.utils.Timer;

import mx.events.FlexEvent;
import mx.graphics.codec.JPEGEncoder;
import mx.logging.ILogger;
import mx.logging.Log;

private var request:URLRequest;
private var loader:URLLoader;
//RGCR: Why are we initializing with dummy values..The dummy values are wrong, they should be numbers
private var fmsIP:String="127.0.0.1";
private var fmsPort:int=1935;
private var fmsAppName:String="collaboration_module";
private var lectureId:Number=0;
private var classNameDetail:String="testClass"
private var classType:String="Classroom";
private var classID:Number=0;
private var userName:String="teacher"
private var contentServerIP:String="127.0.0.1";
private var contentServerPort:int=80;
public var videoDriver:String="0";
public var snapshotTimer:Timer;//=new Timer(5000, 0);
/**
*For Log API
*/
private var log:ILogger=Log.getLogger("aview.biometric.SnapshotComponentHandler.as");
/**
 * @public
 * //PNCR: description
 */
public function init():void
{
	request=new URLRequest();
	request.contentType='application/octet-stream';
	request.method=URLRequestMethod.POST;
	loader=new URLLoader();
	loader.addEventListener(Event.COMPLETE, completeHandler);
	loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	//snapshotTimer.addEventListener("timer", timerHandler);
	if (Log.isDebug()) log.debug("initSnapshot");
}

/**
 * @public
 * //PNCR: description
 * @param serverIP of type String
 * @param port of type int
 * @param classID of type String
 * @param userID of type String
 * @param snapshotDelay of type Number
 * 
 */
public function setValues(contentRecordServerIP:String, contentRecordServerPort:int,fmsIP:String,fmsPort:int,fmsAppName:String,lectureId:Number,className:String,classID:Number,classType:String,userName:String,snapshotDelay:Number):void
{
	this.contentServerIP=contentRecordServerIP;
	this.contentServerPort=contentRecordServerPort;
	this.fmsIP=fmsIP;
	this.fmsPort=fmsPort;
	this.fmsAppName=fmsAppName;
	this.lectureId=lectureId;
	this.classNameDetail=className;
	this.classID=classID;
	this.classType=classType;
	this.userName=userName;
	//snapshotTimer.delay=snapshotDelay * 1000; //delay in seconds
	snapshotTimer=new Timer(snapshotDelay * 1000, 0); //delay in seconds
	snapshotTimer.addEventListener("timer", timerHandler);
	if (Log.isDebug()) log.debug("setValues::snapshotDelay="+snapshotDelay);
}

/**
 * @public
 * //PNCR: description
 * @param e of type Event
 */
public function ioErrorHandler(e:Event):void
{
	if (Log.isInfo()) log.info("ioErrorHandler");
}

/**
 * @public
 * //PNCR: description
 * @param e of type Event
 */
public function completeHandler(e:Event):void
{
	if (Log.isInfo()) log.info("completeHandler");
}

/**
 * @public
 * //PNCR: description
 * @param event of type TimerEvent
 */
public function timerHandler(event:TimerEvent):void
{
	if(Log.isInfo()) log.info("timerHandler: " + event);
	captureImage(faceImage);
}

/**
 * @public
 * //PNCR: description
 */
public function takeSnapshot():void
{
	if(Log.isDebug()) log.debug("takeSnapshot: " + snapshotTimer.running);
	if (!snapshotTimer.running && snapshotTimer.delay != 0)
	{
		snapshotTimer.start();
	}
}
/**
 * @public
 * //PNCR: description
 */
public function stopSnapshotTimer():void
{
	if(Log.isDebug()) log.debug("stopSnapshotTimer: " + snapshotTimer.running);
	if (snapshotTimer.running)
	{ 
		snapshotTimer.stop();
	}
}

/**
 * @public
 * //PNCR: description
 * @param videoDriver of type String
 */
public function setCameraDriver(videoDriver:String):void
{
	if(Log.isInfo()) log.info("setCameraDriver" + videoDriver);
	var cam:Camera=Camera.getCamera(videoDriver);
	//cam.setMode(640, 480, 10, true);
	faceImage.attachCamera(cam);
}

/**
 * @public
 * //PNCR: description
 * @param comp of type DisplayObject 
 */
public function captureImage(comp:DisplayObject):void
{
	var bitmapData:BitmapData=new BitmapData(comp.width, comp.height, true, 0xffffff);
	bitmapData.draw(comp);
	
	//var pngenc:PNGEncoder = new PNGEncoder();
	//var imageData:ByteArray = pngenc.encode(bitmapData);
	var jpgenc:JPEGEncoder=new JPEGEncoder(80);
	var imageData:ByteArray=jpgenc.encode(bitmapData);
	
	//filename: yyyymmdd-hh-mm-ss-userID.xxx
	//var date:Date=new Date();
	//var filename:String=date.getFullYear()+""+(date.getMonth()+1)+""+date.getDate()+"-"+date.getHours()+"-"+date.getMinutes()+"-"+date.getSeconds()+"-"+userID+".jpg";
	
	// -- set up correct url request using post in binary mode
	request.url="http://" + contentServerIP + ":" + contentServerPort + "/AVScript/AVCSnapshot/savePhoto.php?fmsIP="+fmsIP+"&fmsPort="+fmsPort+"&fmsAppName="+fmsAppName+"&lectureId="+lectureId+"&className="+classNameDetail+"&classID=" + classID +"&classType="+classType+ "&userName=" + userName + "&fileName=" + userName + ".jpg";
	request.data=imageData;
	loader.load(request);
	if(Log.isDebug()) log.debug("captureImage::URL="+request.url);
}
