package edu.amrita.aview.core.whiteboard.drawing_object
{
	
	import edu.amrita.aview.core.whiteboard.Shapepoint;
	import edu.amrita.aview.core.whiteboard.WhiteboardShapeSprite;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class Pencil
	{
		public var lineThickness:Number;
		public var lineColor:String;
		public var lineAlpha:Number;
		public var userDrawingShape:Shape;
		public var minimumXY:Point;
		public var scaleFactor:Point;
		public function Pencil()
		{
		}
		public function draw(parent:Sprite, xPos:Number, yPos:Number, newObject:Boolean=false):void{
			if (newObject) {
				userDrawingShape = new Shape();
				userDrawingShape.graphics.moveTo(xPos, yPos);
				parent.addChild(userDrawingShape);
			}
			else{
				userDrawingShape.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				userDrawingShape.graphics.lineTo(xPos, yPos);
				userDrawingShape.graphics.moveTo(xPos, yPos);
			}
		}
		
		public function drawFinish(objectName:String):void{
			userDrawingShape.name = objectName;
		}
		
		public function smoothLines(lineArray:Array,shapeSprite:WhiteboardShapeSprite):WhiteboardShapeSprite {
			//var g:Graphics = shapeSprite.graphics;
			//shapeSprite.graphics.clear();
			var line: Object;
			var p1: Object;
			var p2: Object;
			var prevMidPoint: Point;
			var midPoint: Point;
			var skipPoints: int = 2; //default 2	
			var shapePoints:Array = new Array();
			//for (var j: int = 0; j < lineArray.length; j++) {
				line = lineArray
				//shapeSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
				//trace( "line : " + j + " - " + line );
				prevMidPoint = null;
				midPoint = null;
				for (var i: int = skipPoints; i < line.length; i++) {
					if (i % skipPoints == 0) {
						p1 = line[i - skipPoints];
						p2 = line[i];
						
						midPoint = new Point(p1.x + (p2.x - p1.x) / 2, p1.y + (p2.y - p1.y) / 2);
						
						// draw the curves:
						if (prevMidPoint) {
							shapeSprite.graphics.moveTo(applyScaleFactor(prevMidPoint.x,"x"),applyScaleFactor(prevMidPoint.y,"y"));
							shapeSprite.graphics.curveTo(applyScaleFactor(p1.x,"x"), applyScaleFactor(p1.y,"y")
								, applyScaleFactor(midPoint.x,"x"),applyScaleFactor(midPoint.y,"y"));
						} else {
							// draw start segment:
							shapeSprite.graphics.moveTo(applyScaleFactor(p1.x,"x"), applyScaleFactor(p1.y,"y"));
							shapeSprite.graphics.lineTo(applyScaleFactor(midPoint.x,"x"),applyScaleFactor(midPoint.y,"y"));
						}
						prevMidPoint = midPoint;
					} 
					//draw last stroke
					if (i == line.length - 1) {
						shapeSprite.graphics.lineTo(applyScaleFactor(line[i].x,"x"),applyScaleFactor(line[i].y,"y"));
					}
					/*var shapePoint:Shapepoint = new Shapepoint();
					shapePoint.x = midPoint.x;
					shapePoint.y = midPoint.y;
					shapePoints.push(shapePoint)*/
				}
			//}
			return shapeSprite;
		}
		
		public function applyScaleFactor(point:int,x:String="x"):Number{
			return x=="x" ? (point - minimumXY.x) * scaleFactor.x : (point - minimumXY.y) * scaleFactor.y;	
		}
		
		//*********** Temporary testing functions ************// 
		public function drawFreeHandAndEraser(points:Array, parent:Sprite,btnEraser:*,scratchArea:*,whiteboardShape:*):void{
			var shape:Shape=new Shape();
			parent.addChild(shape);
			if (!btnEraser.enabled)
			{
				shape.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
			}
			else
			{
				shape.graphics.lineStyle(2, 0x990000, .75);
			}
			shape.graphics.moveTo(points[0].x,points[0].y);
			for(var i:uint=1;i<points.length;i++)
			{
				shape.graphics.lineTo(points[i].x,points[i].y);
			}
			if(parent==scratchArea)
			{
				shape.name=whiteboardShape.shapeName;
			}
		}
		
		public function drawFreeHandAndEraserO(points:Array, parent:Sprite,btnEraser:*,scratchArea:*,whiteboardShape:*):Shape
		{
			
			var triangleHeight:uint = 100; 
			var triangle:Shape = new Shape(); 
			
			// red triangle, starting at point 0, 0 
			triangle.graphics.beginFill(0xFF0000); 
			triangle.graphics.lineStyle(2, 0x990000, .75);
			triangle.graphics.moveTo(triangleHeight / 2, 0); 
			triangle.graphics.lineTo(triangleHeight, triangleHeight); 
			
			// green triangle, starting at point 200, 0 
			triangle.graphics.beginFill(0xFF0000); 
			triangle.graphics.lineStyle(2, 0x990000, .75);
			triangle.graphics.moveTo(200 + triangleHeight / 2, 0); 
			triangle.graphics.lineTo(200 + triangleHeight, triangleHeight); 
			
			parent.addChild(triangle);
			return triangle;
			
		}
		public function smoothLinesT(shapePoints:Array,shapeSprite:WhiteboardShapeSprite,minimumXY:*,scaleFactorX:*,scaleFactorY:*):WhiteboardShapeSprite {
			//shapeSprite.graphics.clear();
			//shapeSprite.graphics.lineStyle(lineThickness, uint(lineColor), lineAlpha);
			for (var i:int=1; i < shapePoints.length; i++){
				try{
					shapeSprite.graphics.lineTo((shapePoints[i].x - minimumXY.x) * scaleFactorX, (shapePoints[i].y - minimumXY.y) * scaleFactorY);
				}
				catch (err:Error){
					trace("Error in drawShape method:"+err.getStackTrace());
				}
				
			}
			return shapeSprite;
		}
		
		/*********************OLD Functions **************************/
		
		public function smoothLines_Old(lineArray:Array,shapeSprite:WhiteboardShapeSprite):WhiteboardShapeSprite {
			var line:Array = cleanupLinePoints(lineArray);
			var p1: Object;
			var p2: Object;
			var prevMidPoint: Point;
			var midPoint: Point;
			prevMidPoint = null;
			midPoint = null;
			for (var i: int = 1; i < line.length; i++) {
				p1 = line[i - 1];
				p2 = line[i];
				
				midPoint = new Point(p1.x + (p2.x - p1.x) / 2, p1.y + (p2.y - p1.y) / 2);
				
				// draw the curves:
				if (prevMidPoint) {
					shapeSprite.graphics.moveTo(applyScaleFactor(prevMidPoint.x,"x"),applyScaleFactor(prevMidPoint.y,"y"));
					shapeSprite.graphics.curveTo(applyScaleFactor(p1.x,"x"), applyScaleFactor(p1.y,"y")
						, applyScaleFactor(midPoint.x,"x"),applyScaleFactor(midPoint.y,"y"));
				} else {
					// draw start segment:
					shapeSprite.graphics.moveTo(applyScaleFactor(p1.x,"x"), applyScaleFactor(p1.y,"y"));
					shapeSprite.graphics.lineTo(applyScaleFactor(midPoint.x,"x"),applyScaleFactor(midPoint.y,"y"));
				}
				prevMidPoint = midPoint;
				//draw last stroke
				if (i == line.length - 1) {
					shapeSprite.graphics.lineTo(applyScaleFactor(line[i].x,"x"),applyScaleFactor(line[i].y,"y"));
				}
			}
			return shapeSprite;
		}
		
		private function cleanupLinePoints(lineArray:Array):Array{
			var previosPoint:Object;
			var cleanLine:Array = new Array();
			previosPoint = lineArray[0];
			cleanLine.push(previosPoint);
			for (var i: int = 0; i < lineArray.length; i++) {
				if (previosPoint.x != lineArray[i].x  && previosPoint.y != lineArray[i].y){
					cleanLine.push(lineArray[i]);
					previosPoint = lineArray[i];
				}
				
			}
			return cleanLine;
		}
		
	}
}