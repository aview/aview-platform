package edu.amrita.aview.core.whiteboard.objectHandle
{
	import flash.display.DisplayObject;
	
	import mx.core.Container;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	/**
	 * A class that knows how to add and remove children from a Flex 3 based component using
	 * either addElement, addChild or rawChildren.addChild
	 *
	 * This class could always be used instead of Flex3ChildManager since it understand both,
	 * but it won't compile under the Flex 3 SDK.
	 **/
	
	
	public class Flex4ChildManager implements IChildManager
	{
		[Bindable]
		private var comp:UIComponent=new UIComponent();
		
		public function addElement(container:Object, child:Object):void
		{
			if (container is Group)
			{
				(container as Group).addElement(child as IVisualElement);
			}
			else if (container is Container)
			{
				(container as Container).rawChildren.addChild(child as DisplayObject);
			}
			else
			{
				
				comp.addChild(child as SpriteHandle);
				container.addElement(comp);
			}
		}
		
		public function removeElement(container:Object, child:Object):void
		{
			if (container is Group)
			{
				(container as Group).removeElement(child as IVisualElement);
			}
			else if (container is Container)
			{
				(container as Container).rawChildren.removeChild(child as DisplayObject);
			}
			else
			{
				comp.removeChild(child as DisplayObject);
					//container.removeElement(comp);
			}
		}
	}
}
