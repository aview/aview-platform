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
 * File			: AViewDateUtil.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 */
// AKCR: this is a very small utility. Can this be merged with some common utiltiy code?
package edu.amrita.aview.core.shared.util
{
	import mx.formatters.DateFormatter;
	import mx.utils.ObjectUtil;

	//VGCR:-Class Description
	//VGCR:-function Description
	public class AViewDateUtil
	{
		/**
		 *@public 
		 * Constructor
		 */
		public function AViewDateUtil()
		{
		}
		
		/**
		 * Formatter for the date portion in the date time 
		 */
		private static var dateFormatter:DateFormatter = new DateFormatter();
		/**
		 * Formatter for the time portion in the date time 
		 */
		private static var timeFormatter:DateFormatter = new DateFormatter();
		
		//Static block
		/**
		 * Setting the format values for the date and time formatters 
		 */
		{
			dateFormatter.formatString = "DD MMMM YYYY";
			timeFormatter.formatString = "LL.NN A";
		}
		
		/**
		 * Formats the input date & time values to a combined date&time string using the date & time formatters specified.
		 * @param date
		 * @param time
		 * @return String, date & time of the format "DD MMMM YYYY LL.NN A"
		 * 
		 */
		public static function formatDateTime(date:Date,time:Date):String
		{
			var sDate:String=dateFormatter.format(date) + '  ' + timeFormatter.format(time);
			return sDate;
		}
		
		/**
		 * @public 
		 * @param dateStrA of type String
		 * @param dateStrB of type String
		 * @return int
		 * 
		 */
		public static function date_sortCompareFunc(dateStrA:String, dateStrB:String):int
		{
			/* Date.parse() returns an int, but
			ObjectUtil.dateCompare() expects two
			Date objects, so convert String to
			int to Date. */
			
			var dateA:Date=new Date(Date.parse(dateStrA));
			var dateB:Date=new Date(Date.parse(dateStrB));
			return ObjectUtil.dateCompare(dateA, dateB);
		}
	}
}
