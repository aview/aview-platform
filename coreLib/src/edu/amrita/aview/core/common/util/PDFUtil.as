package edu.amrita.aview.core.common.util
{

	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.gclm.helper.LectureHelper;
	import edu.amrita.aview.core.gclm.lecture.LectureComp;
	import edu.amrita.aview.core.shared.components.alert.CustomAlert;
	import edu.amrita.aview.core.shared.util.AViewDateUtil;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.globalization.DateTimeFormatter;
	import flash.net.FileReference;
	import flash.text.ReturnKeyLabel;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexLoader;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.IElement;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.ColumnText;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.pdf.forms.FieldText;
	import org.purepdf.resources.BuiltinFonts;
	
	public class PDFUtil
	{
		private var pdfDocument : PdfDocument ;
		
		private var documentName : String = null;
		
		private var documentExtension : String = ".pdf";
		
		private var font:org.purepdf.Font = null;
		
		private var buffer:ByteArray = new ByteArray();  
		
		public function PDFUtil()
		{
			// constructor do nothing 
		}
		
		//Initiating to create PDf 
		public function createPDF(documentName : String = "Report") : void
		{
			this.documentName = documentName;
			// register 'Helvetica' font
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA, new BuiltinFonts.HELVETICA() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD() );
			// declare the font
			font = new org.purepdf.Font ( org.purepdf.Font.HELVETICA, 12, org.purepdf.Font.NORMAL );
			                            
			var writer:PdfWriter = PdfWriter.create(buffer, PageSize.A4);
			pdfDocument = writer.pdfDocument;	
		}
		
		//Function to open document
		private function openPdfDocument() : void
		{
			// Check if the document is not null and not opened already
			if((pdfDocument != null) && (pdfDocument.opened != true))
			{
				pdfDocument.open();
			}
		}
		
		//Function to close document
		private function closePdfDocument() : void
		{
			// Check if the document is not null and is opened
			if((pdfDocument != null) && (pdfDocument.opened))
			{
				pdfDocument.close();
			}		
		}
		//Initiating to create table
		public function createTable(tableContents:Array,tableName : String, subHeadingDetails:Array ,tableWidth: Vector.<Number>, columnCount : int=1):void
		{
			openPdfDocument();
			addmainHeading(tableName);
			if(subHeadingDetails.length!=0)
			{
				var subHeader:Object = subHeadingDetails.toString().split(",");
				for(var m:int=0;m<subHeader.length;m++)
				{
					addsubHeading(subHeader[m]);
				}
				var newline:Paragraph = new Paragraph("\n");
				pdfDocument.add(newline);
			}
			addTableContent(tableContents, tableWidth, columnCount);
			
		}
		public function addmainHeading(mainHeading:String):void
		{
			openPdfDocument();
			var mainHeader:Paragraph = new Paragraph(mainHeading,new org.purepdf.Font ( org.purepdf.Font.HELVETICA, 14, org.purepdf.Font.BOLD ));
			mainHeader.alignment= Element.ALIGN_JUSTIFIED;
			pdfDocument.add(mainHeader);
		}
		public function addsubHeading(subHeadingDetails:String):void
		{
			openPdfDocument();
			var subHeader:Paragraph = new Paragraph(subHeadingDetails,new org.purepdf.Font ( org.purepdf.Font.HELVETICA, 10, org.purepdf.Font.BOLD ));
			subHeader.alignment=Element.ALIGN_JUSTIFIED;
			pdfDocument.add(subHeader);
		}
		//Adding paragraph content or data by creating paragaraph
		public function addContent(data:String):void
		{
			openPdfDocument();
			var paragraph:Paragraph = new Paragraph(data);
			var newline:Paragraph = new Paragraph("\n");
			paragraph.alignment = Element.ALIGN_CENTER;
			pdfDocument.add(paragraph);
			pdfDocument.add(newline);
		}
		
		//Rows are added depending on content length
		private function addTableContent(tableContent:Array,tableWidth:Vector.<Number>,columnCount:int=1):void
		{
			// TODO: To make this function to work with as many coulums as mentioned in the parameter 
			var pdfTable : PdfPTable = new PdfPTable(columnCount);
			
			pdfTable.setTotalWidths(tableWidth);
			//pdfTable.widthPercentage = tableWidth;
			pdfTable.horizontalAlignment = Element.ALIGN_LEFT;
			for(var k:int = 0; k < tableContent.length; k++)
			{
				//checking the table content contain error message
				if(tableContent.indexOf("User Not attended for this correponding lecture")!=-1)
				{
					addContent(tableContent[k]);
				}
				else
				{
					var tablevalues:Object=tableContent[k];
					for(var l:int = 0; l < tablevalues.length; l++)
					{
						pdfTable.addStringCell(tablevalues[l]);
					}					
				}				
			}
			tableContent.length = 0;
			pdfDocument.add(pdfTable);
			var newline:Paragraph = new Paragraph("\n");
			pdfDocument.add(newline);
		}
		//Function to save document
		public function save():void
		{
			//this code assument the pdf is already opened
			//TODO To check if user calls this function without creating pdf
			closePdfDocument();
			var fileReference: FileReference = new FileReference();
			//Fix for Bug #20311 Start
			//Added event listner for document cancelled
			fileReference.addEventListener(Event.CANCEL,documentEventHandler);
			//Added event listner for document complete
			fileReference.addEventListener(Event.COMPLETE,documentEventHandler);
			//Fix for Bug #20311 End
			fileReference.save(buffer, documentName + documentExtension);
		}
		//Fix for Bug #20311 Start
		// Downloaded Notification for Cancel
		private function documentEventHandler(event:Event):void
		{
			switch(event.type)
			{
				case Event.CANCEL:
				{
					
					Alert.show("Document not saved","Information");
					break;
				}
				case Event.COMPLETE :
				{
					
					Alert.show("Document saved successfully","Information");
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		//Fix for Bug #20311 End
	}
}

