////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: ContentOperationEvent.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *ContentOperationEvent is a custom event class for content operation like upload,download,folder creation.
 *
 */
package edu.amrita.aview.common.components.fileManager.events
{
	import flash.events.Event;
	import flash.net.FileReference;
	/**
	 * 	ContentOperationEvent is a custom event class for content operation like upload,download,folder creation.
	 *  This calss is extends from Event class.
	 *  User can dispatch ContentOperationEvent while user establish any content operations .
	 */
	public class ContentOperationEvent extends Event
	{
		/**
		 * Event Type for download
		 */		
		public static const DOWLOAD:String="Download";
		/**
		 * Event Type for upload
		 */		
		public static const UPLOAD:String="Upload";
		/**
		 * Event Type for delete
		 */		
		public static const DELETE:String="Delete";
		/**
		 * Event Type for copy
		 */		
		public static const COPY:String="Copy";
		/**
		 * Event Type for create folder
		 */		
		public static const CREATFOLDER:String="CreateFolder";		
		/**
		 * Event Type for CHECKEXISTANCE
		 */
		public static const CHECKEXISTANCE:String="CheckFileExistance";
		/**
		 * Event Type for Filelist
		 */		
		public static const FILELIST:String="FileList";
		/**
		 * Event Type for common shared file list
		 */		
		public static const SHAREDFILELIST:String="SharedFileList";
		/**
		 * Event Type for upload
		 */		
		public static const PREINITILIZEUPLOAD:String="PreInitilizeUpload";
		/**
		 * Event Type for selection in file list
		 */		
		public static const SELECTION:String="Selection";
		/**
		 * For store the value of folder path 
		 */		
		private var _folderPath:String;
		/**
		 * For store the value of file name 
		 */		
		private var _fileName:String;
		/**
		 * For store the value of file path 
		 */		
		private var _filePath:String;
		/**
		 * For store the value of file refernce 
		 */		
		private var _fileReference:FileReference;
		/**
		 * For store the value of source path of copying file 
		 */		
		private var _sourcePath:String;
		/**
		 * For store the value of destination path of copying file 
		 */		
		private var _destinationPath:String;
		/**
		 * For store the value of folder name 
		 */		
		private var _folderName:String
		/**
		 * For store the value of selected item 
		 */		
		private var _selectedItem:XML;
		/**
		 *  For store the value of selected area
		 */		
		private var _selectedArea:String;
		/**
		 *  For store the value of root folder
		 */		
		private var _rootFolder:String;
		
		/**
		 * @public 
		 * set the folder path 
		 * @param data of type String
		 * 
		 */
		public function set folderPath(data:String):void
		{
			_folderPath=data;
		}
		
		/**
		 * @public
		 * get the file name 
		 * @return String
		 * 
		 */
		public function get fileName():String
		{
			return _fileName;
		}
		
		/**
		 * @public 
		 * set the file name 
		 * @param data of type String
		 * 
		 */
		public function set fileName(data:String):void
		{
			_fileName=data;
		}
		
		/**
		 * @public 
		 * get the folder path 
		 * @return String
		 * 
		 */
		public function get folderPath():String
		{
			return _folderPath;
		}
		
		/**
		 * @public 
		 * set the file reference 
		 * @param data of type FileReference
		 * 
		 */
		public function set fileReference(data:FileReference):void
		{
			_fileReference=data;
		}
		
		/**
		 * @public
		 * Get the file reference 
		 * @return FileReference
		 * 
		 */
		public function get fileReference():FileReference
		{
			return _fileReference;
		}
		
		/**
		 * @public 
		 * set the file path 
		 * @param data of type String
		 * 
		 */
		public function set filePath(data:String):void
		{
			_filePath=data;
		}
		
		/**
		 * @public
		 * Get the file path 
		 * @return String
		 * 
		 */
		public function get filePath():String
		{
			return _filePath;
		}
		
		/**
		 * @public 
		 * set the source path
		 * @param data of type String
		 * 
		 */
		public function set sourcePath(data:String):void
		{
			_sourcePath=data;
		}
		
		/**
		 * @public
		 * Get the source path
		 * @return String
		 * 
		 */
		public function get sourcePath():String
		{
			return _sourcePath;
		}
		
		/**
		 * @public 
		 * set the destination path
		 * @param data of type String
		 * 
		 */
		public function set destinationPath(data:String):void
		{
			_destinationPath=data;
		}
		
		/**
		 * @public
		 * Get the destination path
		 * @return String
		 * 
		 */
		public function get destinationPath():String
		{
			return _destinationPath;
		}
		
		/**
		 * @public 
		 * set the root folder
		 * @param data of type String
		 * 
		 */
		public function set rootFolder(data:String):void
		{
			_rootFolder=data;
		}
		
		/**
		 * @public
		 * Get the root folder
		 * @return String
		 * 
		 */
		public function get rootFolder():String
		{
			return _rootFolder;
		}
		
		/**
		 * @public 
		 * set the folder name
		 * @param data of type String
		 * 
		 */
		public function set folderName(data:String):void
		{
			_folderName=data;
		}
		
		/**
		 * @public 
		 *get the Folder name
		 * @return String
		 * 
		 */
		public function get folderName():String
		{
			return _folderName;
		}
		
		/**
		 * @public 
		 * set the selected item
		 * @param data of type XML
		 * 
		 */
		public function set selectedItem(data:XML):void
		{
			_selectedItem=data;
		}
		
		/**
		 * @public
		 * Get the selected item
		 * @return XML
		 * 
		 */
		public function get selectedItem():XML
		{
			return _selectedItem;
		}
		
		/**
		 * @public 
		 * set the selected Area
		 * @param data of type String
		 * 
		 */
		public function set selectedArea(data:String):void
		{
			_selectedArea=data;
		}
		
		/**
		 *@public
		 * Get the selected Area
		 * @return String
		 * 
		 */
		public function get selectedArea():String
		{
			return _selectedArea;
		}
		
		/**
		 * @public 
		 * Constructor
		 * @param type of type String
		 * @param bubbles of type Boolean default value=false
		 * @param cancelable of type Boolean default value =false
		 * 
		 */
		public function ContentOperationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @public 
		 * @return Event
		 * 
		 */
		override public function clone():Event
		{
			return new ContentOperationEvent(type);
		}
	}
}
