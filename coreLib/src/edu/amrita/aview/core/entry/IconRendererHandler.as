import flash.utils.ByteArray;

// ActionScript file
override public function set label(value:String):void
{
	super.label=value;
	labelDisplay.text=label;
}

public function set ico(value:ByteArray):void
{
	icon1.load(value);

}
