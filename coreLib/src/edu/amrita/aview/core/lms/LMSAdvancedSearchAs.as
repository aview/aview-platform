import mx.core.FlexGlobals;
import mx.managers.PopUpManager;
//Icons
[Bindable]
[Embed(source="assets/images/Search.png")]
public var SearchIcon:Class;

[Bindable]
[Embed(source="assets/images/Refresh.png")]
public var RefreshIcon:Class;

[Bindable]
public var classSelectedIndex:int=0;

[Bindable]
public var date:String='';

[Bindable]
public var lectureKeyWord:String='';

[Bindable]
public var topic:String='';

/* Issue No 466 is fixed */
private function checkForTooltip():void{
	if (datef.text != "")
		datef.toolTip="Doubleclick to clear";
}

private function reset():void{
	datef.open();
	var curDate:Date=new Date();
	datef.displayedMonth=curDate.getMonth();
	datef.displayedYear=curDate.getFullYear();
	datef.selectedDate=null;
	datef.close();
	keyWord.text="";
	txtTopic.text="";
	cmbClass.selectedItem="";
	
}

private function closeAdvanceSearch():void{
	PopUpManager.removePopUp(this);
}
// ActionScript file
