// ActionScript file
public function removeSignalStrength():void{
	lbl1.setStyle("backgroundColor", "#FFFFFF");
	lbl2.setStyle("backgroundColor", "#FFFFFF");
	lbl3.setStyle("backgroundColor", "#FFFFFF");
	lbl4.setStyle("backgroundColor", "#FFFFFF");
	lbl5.setStyle("backgroundColor", "#FFFFFF");
}

public function showSignalStrength(signalValue:int):void{
	removeSignalStrength();
	if (signalValue > 20 && signalValue < 40){
		lbl1.setStyle("backgroundColor", "#ff0000");
	}
	else if (signalValue >= 40 && signalValue < 60){
		lbl1.setStyle("backgroundColor", "#ff0000");
		lbl2.setStyle("backgroundColor", "#ff0000");
	}
	else if (signalValue >= 60 && signalValue < 80){
		lbl1.setStyle("backgroundColor", "#f97332");
		lbl2.setStyle("backgroundColor", "#f97332");
		lbl3.setStyle("backgroundColor", "#f97332");
	}
	else if (signalValue >= 80 && signalValue < 100){
		lbl1.setStyle("backgroundColor", "#f97332");
		lbl2.setStyle("backgroundColor", "#f97332");
		lbl3.setStyle("backgroundColor", "#f97332");
		lbl4.setStyle("backgroundColor", "#f97332");
	}
	else if (signalValue >= 100){
		lbl1.setStyle("backgroundColor", "#9df571");
		lbl2.setStyle("backgroundColor", "#9df571");
		lbl3.setStyle("backgroundColor", "#9df571");
		lbl4.setStyle("backgroundColor", "#9df571");
		lbl5.setStyle("backgroundColor", "#9df571");
	}
}
