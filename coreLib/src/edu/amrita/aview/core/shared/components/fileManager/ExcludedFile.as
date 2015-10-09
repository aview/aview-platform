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
 * File			: ExcludedFile.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *This class for setting  all the exclussion operations.
 *
 */
package edu.amrita.aview.core.shared.components.fileManager
{
	
	/**
	 * This class for setting  all the exclussion operations.
	 * @author haridasanpc
	 * 
	 */
	public class ExcludedFile
	{
		/**
		 * @public 
		 * Initilze the values for exclusion
		 * @param excludedFilePattern of type String
		 * @param excludedOperation of type String
		 * @param comparisionContent of type String
		 * @param comparisonMethod of type String
		 * @param customMessage of type String
		 * 
		 */
		public function ExcludedFile(excludedFilePattern:String, excludedOperation:String, comparisionContent:String, comparisonMethod:String, customMessage:String)
		{
			this.filePattern=excludedFilePattern;
			this.operation=excludedOperation;
			this.comparisionContent=comparisionContent;
			this.comparisonMethod=comparisonMethod;
			this.customMessage=customMessage;
		}
		/**
		 * Referd for file patterns
		 */		
		public var filePattern:String=null;
		/**
		 * Referd for file Operations
		 */		
		public var operation:String=null;
		/**
		 * Referd for Comparison content methods
		 */		
		public var comparisionContent:String=null;
		/**
		 * Referd for  Commaprison methods
		 * 
		 */		
		public var comparisonMethod:String=null;
		/**
		 * Referd for Custom messages
		 */		
		public var customMessage:String=null;
	
	}
}
