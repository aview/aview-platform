package edu.amrita.aview.core.shared.components.CustomTab
{
	import mx.containers.Canvas;
	
	import spark.components.BorderContainer;

	public class TabSkin extends BorderContainer
	{
		override protected function updateDisplayList(w : Number, h : Number) : void
		{
			this.styleName = "tab";
			
			super.updateDisplayList (w, h);
		}
		
	}
}