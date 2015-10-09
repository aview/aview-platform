package edu.amrita.aview.core.whiteboard.drawing_object
{
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class Eraser
	{
		
		public var thickness:Number;
		public var color:String;
		public var alpha:Number;
		private var userDrawingShape:Shape;
		public function Eraser()
		{
		}
		public function draw(parent:Sprite, xPos:Number, yPos:Number, newObject:Boolean=false):void{
			if (newObject) {
				userDrawingShape = new Shape();
				userDrawingShape.graphics.moveTo(xPos, yPos);
				parent.addChild(userDrawingShape);
			}
			else{
				userDrawingShape.graphics.lineStyle(thickness, uint(color), alpha,false,LineScaleMode.NORMAL,CapsStyle.SQUARE);
				userDrawingShape.graphics.lineTo(xPos, yPos);
				userDrawingShape.graphics.moveTo(xPos, yPos);
			}
		}
		
		public function drawFinish(objectName:String):void{
			userDrawingShape.name = objectName;
			userDrawingShape = null;
		}
		
	}
}