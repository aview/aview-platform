// ActionScript file
import edu.amrita.aview.playback.oldPlayback.Print2Flash.PageChangedEvent;
import edu.amrita.aview.playback.oldPlayback.Print2Flash.PageLoadedEvent;
import edu.amrita.aview.playback.oldPlayback.Print2Flash.Selection;
import edu.amrita.aview.playback.oldPlayback.Print2Flash.ToolChangedEvent;
import edu.amrita.aview.playback.oldPlayback.Print2Flash.VisibleAreaEvent;
import edu.amrita.aview.playback.oldPlayback.Print2Flash.ZoomChangedEvent;

import flash.events.Event;
import flash.events.StatusEvent;
import flash.net.LocalConnection;
import flash.utils.clearInterval;

import mx.controls.*;
import mx.utils.*;

private var connstr:String;
private var APILC:LocalConnection;
private var LoadedInt:Number;
private var Loaded:Boolean;

override public function get source():Object
{
	return super.source;
}

override public function set source(value:Object):void
{
	connstr="_" + UIDUtil.createUID();
	if (APILC != null)
		APILC.close();
	APILC=new LocalConnection();
	var strVal:String=value.toString()
	if (strVal.indexOf("?") != -1)
		strVal+="&";
	else
		strVal+="?";
	;
	strVal+="connstr=" + connstr + "&conndomain=" + APILC.domain;
	Loaded=false
	super.source=strVal;
	
	APILC.client=this;
	APILC.allowDomain("*");
	APILC.addEventListener(StatusEvent.STATUS, OnAPILCStatus);
	APILC.connect(connstr + "_Events");
}

private function OnAPILCStatus(E:StatusEvent):void
{
	if (!Loaded)
		Loaded=E.level == "status";
}

private var CBNum:Number=1;
private var CBArray:Object=new Object()

private function RegisterCBFunc(CBFunc:Function):String
{
	var ID:String=(CBNum++).toString()
	CBArray[ID]=CBFunc
	return ID;
}

private function CallCBFunc(ID:String, Param:Object):void
{
	CBArray[ID](Param);
	delete CBArray[ID];
}

public function CallBack(CBID:String, Param:Object):void
{
	CallCBFunc(CBID, Param)
}

private function CheckLoaded():void
{
	if (!Loaded)
		this.Init();
	else
	{
		clearInterval(LoadedInt);
		this.dispatchEvent(new Event("onLoaded"));
	}
}

private function Init():void
{
	APILC.send(connstr, "init", this.width, this.height);
}

// API Functions
public function setCurrentPage(page:Number):void
{
	APILC.send(connstr, "setCurrentPage", page);
}

public function getCurrentPage(CBFunc:Function):void
{
	APILC.send(connstr, "getCurrentPage", RegisterCBFunc(CBFunc));
}

public function setSize(width:Number, height:Number):void
{
	APILC.send(connstr, "setSize", width, height);
	this.width=width
	this.height=height
}

public function setScrollPosition(pos:edu.amrita.aview.playback.oldPlayback.Print2Flash.Point):void
{
	APILC.send(connstr, "setScrollPosition", pos);
}

public function getMaxScrollPosition(CBFunc:Function):void
{
	APILC.send(connstr, "getMaxScrollPosition", RegisterCBFunc(CBFunc));
}

public function getScrollPosition(CBFunc:Function):void
{
	APILC.send(connstr, "getScrollPosition", RegisterCBFunc(CBFunc));
}

public function PreviousPage():void
{
	APILC.send(connstr, "PreviousPage");
}

public function NextPage():void
{
	APILC.send(connstr, "NextPage");
}

public function getVisibleArea(CBFunc:Function):void
{
	APILC.send(connstr, "getVisibleArea", RegisterCBFunc(CBFunc));
}

public function setVisibleArea(area:Object):void
{
	APILC.send(connstr, "setVisibleArea", area);
}

public function setCurrentZoom(zoom:Object):void
{
	APILC.send(connstr, "setCurrentZoom", zoom);
}

public function getCurrentZoom(CBFunc:Function):void
{
	APILC.send(connstr, "getCurrentZoom", RegisterCBFunc(CBFunc));
}

public function setCurrentTool(tool:String):void
{
	APILC.send(connstr, "setCurrentTool", tool);
}

public function getCurrentTool(CBFunc:Function):void
{
	APILC.send(connstr, "getCurrentTool", RegisterCBFunc(CBFunc));
}

public function setControlVisibility(mask:Number):void
{
	APILC.send(connstr, "setControlVisibility", mask);
}

public function SearchText(text:String, CBFunc:Function):void
{
	APILC.send(connstr, "SearchText", RegisterCBFunc(CBFunc), text);
}

public function findNext(CBFunc:Function):void
{
	APILC.send(connstr, "findNext", RegisterCBFunc(CBFunc));
}

public function ResetTextSearch():void
{
	APILC.send(connstr, "ResetTextSearch");
}

public function setFindText(text:String):void
{
	APILC.send(connstr, "setFindText", text);
}

public function getFindText(CBFunc:Function):void
{
	APILC.send(connstr, "getFindText", RegisterCBFunc(CBFunc));
}

public function setTextSelectionRange(sel:Object):void
{
	APILC.send(connstr, "setTextSelectionRange", sel);
}

public function getTextSelectionRange(CBFunc:Function):void
{
	APILC.send(connstr, "getTextSelectionRange", RegisterCBFunc(CBFunc));
}

public function getNumberOfPages(CBFunc:Function):void
{
	APILC.send(connstr, "getNumberOfPages", RegisterCBFunc(CBFunc));
}

public function OpenHelpPage():void
{
	APILC.send(connstr, "OpenHelpPage");
}

public function OpenInNewWindow():void
{
	APILC.send(connstr, "OpenInNewWindow");
}

public function printTheDocument():void
{
	APILC.send(connstr, "printTheDocument");
}

public function Rotate():void
{
	APILC.send(connstr, "Rotate");
}

public function getLoadedPages(CBFunc:Function):void
{
	APILC.send(connstr, "getLoadedPages", RegisterCBFunc(CBFunc));
}

public function setLanguage(lang:String):void
{
	APILC.send(connstr, "setLanguage", lang);
}

public function adjustToolbarColor(hue:Number, saturation:Number, brightness:Number, contrast:Number):void
{
	APILC.send(connstr, "adjustToolbarColor", hue, saturation, brightness, contrast);
}

public function enableScrolling(enable:Boolean):void
{
	APILC.send(connstr, "enableScrolling", enable);
}

public function getSelectedText(CBFunc:Function):void
{
	APILC.send(connstr, "getSelectedText", RegisterCBFunc(CBFunc));
}

public function setVisiblePages(from:Number, _to:Number):void
{
	APILC.send(connstr, "setVisiblePages", from, _to);
}

// API Events
public function onPageChanged(page:Number):void
{
	this.dispatchEvent(new PageChangedEvent(page));
}

public function onVisibleAreaChanged(area:Object):void
{
	this.dispatchEvent(new VisibleAreaEvent(area));
}

public function onZoomChanged(zoom:Number):void
{
	this.dispatchEvent(new ZoomChangedEvent(zoom));
}

public function onToolChanged(tool:String):void
{
	this.dispatchEvent(new ToolChangedEvent(tool));
}

public function onSelection(sel:Object):void
{
	this.dispatchEvent(new Selection(sel));
}

public function onPageLoaded(page:Number):void
{
	this.dispatchEvent(new PageLoadedEvent(page));
}
