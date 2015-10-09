package edu.amrita.aview.core.whiteboard{
	applicationType::mobile{
		import edu.amrita.aview.core.whiteboard.mobileTools.DynamicTextArea;
	}
	applicationType::DesktopWeb{
		import edu.amrita.aview.core.whiteboard.objectHandle.MoveableTextArea;
	}
	
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import edu.amrita.aview.core.whiteboard.drawing_object.Pencil;
	import edu.amrita.aview.core.userPreference.ConfigFileReader;
	import edu.amrita.aview.core.entry.ClassroomContext;
	
	public class WhiteboardShape extends EventDispatcher{
		
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.whiteboard.WhiteboardShape.as");
		
		public function WhiteboardShape(){
			shapePoints=new Array();
			ctime=-1;
		}
		/**
		 * @private
		 * Function to find the minimum x point and y point from the given array of points.
		 * This value is used to find the exact point/location of line inside a drawing sprite.  
		 */
		public static function findMinimumXY(points:Array):Point{
			var smallX:Number=points[0].x;
			var smallY:Number=points[0].y;
			for (var i:uint=1; i < points.length; i++){
				if (points[i].x < smallX) smallX=points[i].x;
				if (points[i].y < smallY) smallY=points[i].y;
				//shape.graphics.lineTo(points[i].x-points[0].x,points[i].y-points[0].y);
			}
			return new Point(smallX, smallY);
		}
		/**
		 * Initialize a whiteboard shape object. 
		 * @param: shape type of XML. 
		 * Sample shape XML 
		 * 	"<shape shapeId="3" toolName="c" lineThickness="3" lineColor="0x000000" lineAlfa="1" pageNo="1" drawnAreaWidth="742" drawnAreaHeight="513" drawnBy="moderator4" isRecorded="false" shapeName="moderator41402651533131" ignoreSync="false" ignoreDrawing="false" shapeX="-1" shapeY="-1">
		 * 	<content>
		 * 	<point x="407" y="92"/>
		 * 	<point x="430" y="127"/>
		 * 	</content>
		 * 	</shape>"
		 */
		public function initByXML(shape:XML):void{
			this.shapeId=shape.@shapeId;
			this.toolName=shape.@toolName;
			this.lineColor=shape.@lineColor;
			this.lineThickness=shape.@lineThickness;
			this.lineAlfa=shape.@lineAlfa
			this.drawnBy=shape.@drawnBy;
			this.drawnAreaWidth=shape.@drawnAreaWidth;
			this.drawnAreaHeight=shape.@drawnAreaHeight;
			this.pageNo=shape.@pageNo;
			this.shapeName=shape.@shapeName;
			this.isRecorded=shape.@isRecorded == "true" ? true : false; //Boolean(shape.@isRecorded);
			this.ignoreSync=shape.@ignoreSync == "true" ? true : false;
			this.ignoreDrawing=shape.@ignoreDrawing == "true" ? true : false;
			this.shapeX=shape.@shapeX;
			this.shapeY=shape.@shapeY;
			if (this.toolName == "txt"){
				
				this.txtToolFnt=shape.@txtToolFnt;
				this.txt_str=shape.@txt_str;
				this.txtAreaWidth=shape.@txtAreaWidth;
				this.txtAreaHeight=shape.@txtAreaHeight;
			}
			for each (var point:XML in shape.content.children()){
				var shapePoint:Shapepoint=new Shapepoint();
				shapePoint.initByXML(point);
				this.shapePoints.push(shapePoint)
			}
		}
		
		public function initBySO(shapeObj:Object):void{
			this.shapeId=shapeObj.shapeId;
			this.toolName=shapeObj.toolName;
			this.lineColor=shapeObj.lineColor;
			this.lineThickness=shapeObj.lineThickness;
			this.lineAlfa=shapeObj.lineAlfa
			this.drawnBy=shapeObj.drawnBy;
			this.drawnAreaWidth=shapeObj.drawnAreaWidth;
			this.drawnAreaHeight=shapeObj.drawnAreaHeight;
			this.pageNo=shapeObj.pageNo;
			this.shapeName=shapeObj.shapeName;
			this.ignoreSync=shapeObj.ignoreSync;
			this.ignoreDrawing=shapeObj.ignoreDrawing;
			for (var i:int=0; i < shapeObj.shapePoints.length; i++){
				var shapePoint:Shapepoint=new Shapepoint();
				shapePoint.initBySO(shapeObj.shapePoints[i]);
				this.shapePoints.push(shapePoint)
			}
			this.shapeX=shapeObj.shapeX;
			this.shapeY=shapeObj.shapeY;
			
			if (shapeObj.toolName == "txt"){
				
				this.txtToolFnt=shapeObj.txtToolFnt;
				this.txt_str=shapeObj.txt_str;
				this.txtAreaWidth=shapeObj.txtAreaWidth;
				this.txtAreaHeight=shapeObj.txtAreaHeight;
			}
			
		}
		public var shapeId:uint;
		public var toolName:String
		public var lineThickness:uint
		public var lineColor:String;
		public var lineAlfa:Number;
		public var drawnAreaWidth:uint;
		public var drawnAreaHeight:uint;
		public var pageNo:uint;
		public var drawnBy:String;
		public var shapePoints:Array;
		public var ctime:int;
		public var txtToolFnt:uint;
		public var isRecorded:Boolean=false;
		//This is the most repeating element in the xml. So its name is kept short
		//public var sp:Array;
		private var xmlString:String
		public var fnt:uint;
		public var txt_str:String;
		public var txtAreaWidth:uint;
		public var txtAreaHeight:uint;
		public var shapeX:Number=-1;
		public var shapeY:Number=-1;
		public var shapeName:String;
		public var ignoreSync:Boolean=false;
		public var ignoreDrawing:Boolean=false;
		
		/*private function getScaledThickness(originalThickness:Number,scaleFactorX:Number,scaleFactorY:Number):Number{
		if(scaleFactorX == 0 ||  scaleFactorY == 0){
		return originalThickness;
		}
		
		var scaledThickness:Number;
		if(scaleFactorX>scaleFactorY){
		scaledThickness= originalThickness*scaleFactorX;
		}
		else{
		scaledThickness=originalThickness*scaleFactorY;
		}
		return scaledThickness;
		}*/
		private function mouseWheelHandler(event:MouseEvent):void{
			var originalEvent:MouseEvent=event.clone() as MouseEvent;
			
			event.preventDefault();
			event.stopPropagation();
			event.stopImmediatePropagation();
			
			this.dispatchEvent(originalEvent);
		}
		/**
		 * Function to draw shape inside a shape sprite object. 
		 * @param baseWidth type of Number - Width of the parent Canvas. 
		 * @param baseHeight type of Number - Height of the parent Canvas.
		 * @param backgroundColor type of Number - Optional default value 0xffffff.
		 * @return WhiteboardShapeSprite.
		 */
		public function drawShape(baseWidth:Number, baseHeight:Number, backgroundColor:Number=0xffffff):*{
			log.info(" Entered function drawShapes in WhiteboardShape.as with baseWidth " + baseWidth + " and baseHeigh t" + baseHeight);
			//log.info(" In function drawShapes in WhiteboardShape.as with drawnAreaWidth " + drawnAreaWidth + " and drawnAreaHeight " + drawnAreaHeight);
			if (ignoreDrawing){
				return null
			}
			var temp_w:Number=0.0000000000000;
			var temp_h:Number=0.0000000000000;
			var scaleFactorX:Number=0.0000000000000;
			var scaleFactorY:Number=0.0000000000000;
			var shapeSprite:WhiteboardShapeSprite;
			var i:uint;
			scaleFactorX=baseWidth / drawnAreaWidth;
			scaleFactorY=baseHeight / drawnAreaHeight;
			var scaleFactor:Point = new Point(scaleFactorX,scaleFactorY)
			if (baseWidth > 0 && baseHeight > 0 && ((shapePoints && shapePoints.length > 0) || toolName == "txt")){
				shapeSprite=new WhiteboardShapeSprite();
				shapeSprite.drawnBy=this.drawnBy;
				var txtField:* = null;
				if (toolName == "txt"){
					applicationType::DesktopWeb{
						txtField=new MoveableTextArea();
						txtField.drawnBy=this.drawnBy;
						txtField.width=txtAreaWidth;
						txtField.height=txtAreaHeight;
						txtField.text=txt_str;
						txtField.shapeType="txt";
						txtField.x=shapeX * scaleFactorX;
						txtField.y=shapeY * scaleFactorY;
						txtField.setStyle("color", uint(lineColor));
						txtField.setStyle("borderVisible", false);
						txtField.setStyle("contentBackgroundAlpha", 0);
						txtField.setStyle("horizontalScrollPolicy", "off");
						txtField.setStyle("verticalScrollPolicy", "off");
						txtField.setStyle("fontSize", txtToolFnt);
						txtField.selectable=false;
						txtField.editable=false;
					}
					applicationType::mobile{
						//To create dynamic text area.
						txtField = new DynamicTextArea;
						var fontSize:int;
						if(txtAreaWidth == 50 && txtAreaHeight == 50){
							fontSize= Math.abs((txtToolFnt*scaleFactorX));
						}else{
							fontSize= Math.abs((txtToolFnt*scaleFactorX)+1);
						}
						txtField.width=txtAreaWidth;
						txtField.height=txtAreaHeight;
						txtField.text=txt_str;
						txtField.x=shapeX* scaleFactorX;
						txtField.y=shapeY*(baseHeight-5) / drawnAreaHeight;
						txtField.setStyle("color",uint(lineColor));
						txtField.setStyle("fontSize",fontSize);
					}
					txtField.focusEnabled=false;
					txtField.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true, 0, false);
					return txtField;
				}
				else if (shapePoints.length>1){
					//PNCR: added else if condition to avoid value assign delay.
					
					//Bug #15635. For circle the minimum point logic will not work. Take always a center point.
					if (toolName == "c")
						var minimumXY:Point=new Point(shapePoints[0].x,shapePoints[0].y);
					else
						var minimumXY:Point=findMinimumXY(shapePoints);

					var x0:Number=(shapePoints[0].x - minimumXY.x) * scaleFactorX;
					var x1:Number=(shapePoints[1].x - minimumXY.x) * scaleFactorX;
					var y0:Number=(shapePoints[0].y - minimumXY.y) * scaleFactorY;
					var y1:Number=(shapePoints[1].y - minimumXY.y) * scaleFactorY;
					
					if (shapeX > -1){
						shapeSprite.x=shapeX * scaleFactorX;
						shapeSprite.y=shapeY * scaleFactorY;
					}
					else{
						shapeSprite.x=minimumXY.x * scaleFactorX;
						shapeSprite.y=minimumXY.y * scaleFactorY;
					}
					if (toolName == "e"){
						shapeSprite.graphics.lineStyle(lineThickness, backgroundColor, lineAlfa, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
						shapeSprite.shapeType="e";
					}
					else{
						//var scaledThickness:Number = getScaledThickness(lineThickness,scaleFactorX,scaleFactorY);
						shapeSprite.graphics.lineStyle(lineThickness, uint(lineColor))
					}
					shapeSprite.graphics.moveTo(x0, y0);
					
					
					if (toolName == "fh" || toolName == "e"){
						if (toolName == "fh"){
							shapeSprite.shapeType="fh";
						}
						//PNCR: while drawing smoothen the lines
						//Bug #17314. Remove smoothing for eraser. 
						if (toolName == "e" || ConfigFileReader.configValues.Whiteboard.Smoothing.EnableLineSmoothing != 1){ //If smoothing is not required.
							for (i=1; i < shapePoints.length; i++){
								try{
									shapeSprite.graphics.lineTo((shapePoints[i].x - minimumXY.x) * scaleFactorX, (shapePoints[i].y - minimumXY.y) * scaleFactorY);
								}
								catch (err:Error){
									if(Log.isError()) log.error("Error in drawShape method:"+err.getStackTrace());
								}
								
							}
						}
						else{
							var pencil:Pencil = new Pencil();
							pencil.minimumXY = minimumXY
							pencil.scaleFactor = scaleFactor;
							shapeSprite = pencil.smoothLines(shapePoints,shapeSprite); //,minimumXY,scaleFactorX,scaleFactorY
						}
					}
						
						// draw straight line (we can also use s=="st")
						//DRAW_STRAIGHT_LINE#7
					else if (toolName == "st"){
						shapeSprite.shapeType="st";
						shapeSprite.graphics.lineTo(x1, y1);
						
					}
						
						//draw rectangle 
						//DRAW_RECTANGLE#7
					else if (toolName == "r"){
						shapeSprite.shapeType="r";
						shapeSprite.graphics.drawRect(x0, y0, (x1 - x0), (y1 - y0));
						
					}
						
						// draw circle
						//DRAW_CIRCLE#7
					else if (toolName == "c"){
						shapeSprite.shapeType="c";
						var radius:Number=Math.sqrt(Math.pow((x1 - x0), 2) + Math.pow((y1 - y0), 2));
						shapeSprite.graphics.drawCircle(x0 + radius, y0 + radius, radius);
						//PNCR: Bug #15117. After position change, on redraw the object location is changing.
						if (shapeX == -1){ //Only at the time of initial object creation, before any object relocation.
							shapeSprite.x-=radius;
							shapeSprite.y-=radius;
						}
						
					}
				}
				
			}
			return shapeSprite;
		}
		
		public function drawShapePlayBack(baseWidth:Number,baseHeight:Number,backgroundColor:Number):*
		{
			var temp_w:Number=0.0000000000000;
			var temp_h:Number=0.0000000000000;
			var scaleFactorX:Number=0.0000000000000;
			var scaleFactorY:Number=0.0000000000000;
			var shapeSprite:WhiteboardShapeSprite
			var i:uint;
			scaleFactorX=baseWidth / drawnAreaWidth;
			scaleFactorY=baseHeight / drawnAreaHeight;
			if(baseWidth >0 && baseHeight > 0 && ((shapePoints && shapePoints.length>0)||toolName=="txt"))
			{ 
				shapeSprite=new WhiteboardShapeSprite();
				if(toolName == "e")
				{
					shapeSprite.graphics.lineStyle(lineThickness,backgroundColor,lineAlfa,false,LineScaleMode.NORMAL,CapsStyle.SQUARE);
				}
				else
				{
					//var scaledThickness:Number = getScaledThickness(lineThickness,scaleFactorX,scaleFactorY);
					shapeSprite.graphics.lineStyle(lineThickness,uint(lineColor))
				}
				if(toolName=="txt")
				{
					applicationType::DesktopWeb{
						var txtField:MoveableTextArea=new MoveableTextArea;
						txtField.width=txtAreaWidth;
						txtField.height=txtAreaHeight; 
						txtField.text=txt_str;	
						txtField.x=shapeX * scaleFactorX;
						txtField.y=shapeY* scaleFactorY;
						txtField.setStyle("color",uint(lineColor));
						txtField.setStyle("borderVisible","false");
						txtField.setStyle("contentBackgroundAlpha","0");
						txtField.setStyle("horizontalScrollPolicy","off");
						txtField.setStyle("verticalScrollPolicy","off");
						txtField.setStyle("fontSize",txtToolFnt);
						txtField.selectable=false;
						txtField.editable=false;
						txtField.focusEnabled=false;
						txtField.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true, 0, false);
						return txtField;	        	
					}
				}
				else
				{
					shapeSprite.graphics.moveTo(shapePoints[0].x * scaleFactorX,shapePoints[0].y * scaleFactorY);
				}
				
				if (toolName == "fh")
				{
					for (i=1; i < shapePoints.length; i++)
					{
						shapeSprite.graphics.lineTo((shapePoints[i].x* scaleFactorX), (shapePoints[i].y * scaleFactorY));
						
					}
				}
					
					// draw straight line (we can also use s=="st")
					//DRAW_STRAIGHT_LINE#7
				else if (toolName == "st")
				{
					shapeSprite.graphics.lineTo((shapePoints[1].x * scaleFactorX), (shapePoints[1].y * scaleFactorY));
					
				}
					
					//draw rectangle 
					//DRAW_RECTANGLE#7
				else if (toolName == "r")
				{
					shapeSprite.graphics.drawRect((shapePoints[0].x * scaleFactorX), (shapePoints[0].y * scaleFactorY), ((shapePoints[1].x * scaleFactorX) - (shapePoints[0].x* scaleFactorX)), ((shapePoints[1].y * scaleFactorY) - (shapePoints[0].y * scaleFactorY)));
					
				}
					
					// draw circle
					//DRAW_CIRCLE#7
				else if (toolName == "c")
				{
					var radious:Number=Math.sqrt(Math.pow(((shapePoints[1].x * scaleFactorX) - (shapePoints[0].x* scaleFactorX )), 2) + Math.pow(((shapePoints[1].y* scaleFactorY) - (shapePoints[0].y* scaleFactorY)), 2));
					shapeSprite.graphics.drawCircle((shapePoints[0].x * scaleFactorX), (shapePoints[0].y * scaleFactorY), radious);
					
				}
					
					// eraser functioality
					//ERASE#7
				else if (toolName == "e")
				{
					for (i=1; i < shapePoints.length; i++)
					{
						shapeSprite.graphics.lineTo((shapePoints[i].x* scaleFactorX), (shapePoints[i].y * scaleFactorY));
						
					}
				}
				
			}
			return shapeSprite;
		}
		
		
		public function convertToXml():XML{
			var xml:XML=<shape><content></content></shape>
			var pointXml:XML;
			xml.@shapeId=shapeId;
			xml.@toolName=toolName;
			xml.@lineThickness=lineThickness
			xml.@lineColor=lineColor;
			xml.@lineAlfa=lineAlfa
			xml.@pageNo=pageNo
			xml.@drawnAreaWidth=drawnAreaWidth
			xml.@drawnAreaHeight=drawnAreaHeight
			xml.@drawnBy=drawnBy
			xml.@isRecorded=isRecorded.toString();
			xml.@shapeName=shapeName;
			xml.@ignoreSync=ignoreSync;
			xml.@ignoreDrawing=ignoreDrawing;
			xml.@shapeX=shapeX;
			xml.@shapeY=shapeY;
			if (toolName == "txt"){
				
				xml.@txtToolFnt=txtToolFnt;
				xml.@txt_str=txt_str;
				xml.@txtAreaWidth=txtAreaWidth;
				xml.@txtAreaHeight=txtAreaHeight;
			}
			if (ctime != -1){
				xml.@ctime=ctime;
			}
			for (var i:uint=0; i < shapePoints.length; i++){
				var shapePoint:Shapepoint=shapePoints[i] as Shapepoint;
				xml.content.appendChild(shapePoint.convertToXml());
			}
			
			return xml;
		}
		
		private function drawText():void{
			
		}
		
	}
	
}
