package edu.amrita.aview.core.shared.components.CustomTab
{
	import mx.containers.Canvas;
	
	import spark.components.BorderContainer;

	public class SelectedTabSkin extends BorderContainer
	{
		override protected function updateDisplayList(w : Number, h : Number) : void
		{
			this.styleName = "selectedTab";
			
			super.updateDisplayList (w, h);
		}
	}
}