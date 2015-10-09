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
 * File			: ExcludedFileOperation.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *This class is referred for checking in the file operation exclusions
 * 
 *
 *
 */
package edu.amrita.aview.common.components.fileManager
{
	import mx.collections.ArrayCollection;
	
	/**
	 * For checking have any  exlusions in file operations.
	 * @author haridasanpc
	 * 
	 */
	public class ExcludedFileOperation
	{
		/**
		 *Indicating this static  constant variable for to refer a text which is 'Delete'.
		 *This for checking exclusion for file deletion
		 */
		public static const OPERATION_DELETE:String="Delete";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'Create'.
		 *This for checking exclusion for Folder creation
		 */	
		public static const OPERATION_CREATE:String="Create";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'File'.
		 *This for check exclusion for checking the file path
		 */	
		public static const COMPARE_CONTENT_FILE:String="File";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'Folder'.
		 *This for check exclusion for checking the Folder exists
		 */			
		public static const COMPARE_CONTENT_FOLDER:String="Folder";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'File Path'.
		 *This for checking exclusion for  checking the full file path
		 */		
		public static const COMPARE_CONTENT_FILE_PATH:String="File Path";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'Folder Path'.
		 *This for checking exclusion for  checking the full folder path
		 */		
		public static const COMPARE_CONTENT_FOLDER_PATH:String="Folder Path";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'Starting With'.
		 *This for checking exclusion like name satrt with some extra character in file or folder 
		 */			
		public static const COMPARE_METHOD_STARTS_WITH:String="Starting With";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'Full'.
		 *This for checking exclusion like some extra character in file Path  or folder path
		 */		
		public static const COMPARE_METHOD_FULL:String="Full";
		/**
		 *Indicating this static  constant variable for to refer a text which is 'Prefix'.
		 *This for checking exclusion like  some extra character in file's or folder's prefix 
		 */		
		public static const COMPARE_METHOD_PREFIX:String="Prefix";
		
		/**
		 *Collection of all exclusions
		 */	
		private var exclusions:ArrayCollection=new ArrayCollection();
		
		/**
		 * @public 
		 * Here we add all the exclusion to the array
		 * @param filePattern of type String
		 * @param operation of type String
		 * @param comparisionContent of type String
		 * @param comparisonMethod of type String
		 * @param customErrorMessage of type String
		 * 
		 */
		public function addExcludedFileOperation(filePattern:String, operation:String, comparisionContent:String, comparisonMethod:String, customErrorMessage:String):void
		{
			exclusions.addItem(new ExcludedFile(filePattern, operation, comparisionContent, comparisonMethod, customErrorMessage));
		}
		
		/**
		 * @public 
		 * Checking have any exclusion in the given operation
		 * @param file of type String
		 * @param operation of type String
		 * @param comparisionContent of type String
		 * @return String
		 * 
		 */
		// AKCR: please revisit the logic of this function
		public function isFileExcluded(file:String, operation:String, comparisionContent:String):String
		{
			var errorMessage:String="";
			for (var i:int=0; i < exclusions.length; i++)
			{
				var exclusion:ExcludedFile=ExcludedFile(exclusions[i]);
				
				if (exclusion.operation == operation && 
					exclusion.comparisionContent == comparisionContent)
				{
					if (match(file, exclusion.filePattern, exclusion.comparisonMethod))
					{
						if (exclusion.customMessage != null)
						{
							errorMessage=exclusion.customMessage;
						}
						else
						{
							errorMessage=buildErrorMessage(operation, comparisionContent, exclusion.comparisonMethod, exclusion.filePattern);
						}
						break;
					}
				}
			}
			return errorMessage;
		}
		
		/**
		 * @private 
		 * Create cusstom error message for exclusion
		 * @param operation of type String
		 * @param fileType of type String
		 * @param comparisonType of type String
		 * @param filePattern of type String
		 * @return String
		 * 
		 */
		private function buildErrorMessage(operation:String, fileType:String, comparisonType:String, filePattern:String):String
		{
			var errorMessage:String="Can't " + operation + " " + fileType + " with name " + ((comparisonType == COMPARE_METHOD_STARTS_WITH) ? COMPARE_METHOD_STARTS_WITH : "") + //Adds "Starting with"
				filePattern;
			
			return errorMessage;
		}
		
		/**
		 * @private 
		 * Here we checking the prefix and suffix in file path or folder path
		 * @param fileName of type String
		 * @param filePattern of type String
		 * @param comparisonType of type String
		 * @return Boolean
		 * 
		 */
		private function match(fileName:String, filePattern:String, comparisonType:String):Boolean
		{
			var MAIN_FOLDER:String="/VideoShare/";
			var matched:Boolean=false;
			if (comparisonType == COMPARE_METHOD_STARTS_WITH)
			{
				if (fileName.indexOf(filePattern) == 0)
				{
					matched=true;
				}
			}
			else if (comparisonType == COMPARE_METHOD_FULL)
			{
				if (fileName == filePattern)
				{
					matched=true;
				}
				/**For video sharing */
				if (fileName.indexOf(MAIN_FOLDER) != -1 && filePattern != "")
				{
					if ((fileName.indexOf(filePattern)) != -1)
						matched=true;
				}
			}
			else if (comparisonType == COMPARE_METHOD_PREFIX)
			{
				if (filePattern.indexOf(fileName) == 0)
				{
					matched=true;
				}
				if (fileName.indexOf(MAIN_FOLDER) != -1 && filePattern != "")
				{
					if ((filePattern.indexOf(fileName.substring(fileName.indexOf(MAIN_FOLDER), fileName.length) + "/")) != -1)
					{
						matched=true;
					}
				}
			}
			return matched;
		}
	
	}
}
