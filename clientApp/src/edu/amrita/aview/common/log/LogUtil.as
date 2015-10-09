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
 * File			: LogUtil.as
 * Module		: Common
 * Developer(s)	: Ramesh Guntha
 * Reviewer(s)	: Veena Gopal K.V
 *
 * It provides behavior for including date, time, category, and level for the targets.
 * It's initialized from main.mxml.
 *
 */

package edu.amrita.aview.common.log
{
	
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	public class LogUtil
	{
		// AKCR: please use the single line comment format
		/**
		 * The packages & files for which the logger would apply
		 */
		private const categoryFilter:Array=["aview.*", "edu.amrita.aview.*"];
		
		/**
		 * This target writes the log data to the log files based on the initialization
		 */
		private var logFileTarget:LogFileTarget=new LogFileTarget();
		
		/**
		 * This target writes the log data to the console based on the initialization
		 */
		private var traceTarget:TraceTarget=new TraceTarget();
		
		/**
		 *
		 * @public
		 * constructor
		 * Default constructor for this class. Does nothing.
		 *
		 */
		public function LogUtil()
		{
		}
		
		/**
		 *
		 * @public
		 * This function sets Logging properties for logFileTarget and traceTarget.
		 * logFileTarget writes to the Aview_Date.txt file and traceTarget to the console
		 * This function is called from init() in main.mxml
		 *
		 * @return void
		 *
		 */
		public function initLog():void
		{
			/**
			 * Sets logging properties for logFileTarget
			 */
			logFileTarget.filters=categoryFilter;
			logFileTarget.level=LogEventLevel.ALL;
			logFileTarget.includeDate=true;
			logFileTarget.includeTime=true;
			logFileTarget.includeCategory=true;
			logFileTarget.includeLevel=true;
			Log.addTarget(logFileTarget);
			
			/**
			 * Sets logging properties for traceTarget
			 */
			traceTarget.filters=categoryFilter;
			traceTarget.level=LogEventLevel.ALL;
			traceTarget.includeDate=true;
			traceTarget.includeTime=true;
			traceTarget.includeCategory=true;
			traceTarget.includeLevel=true;
			Log.addTarget(traceTarget);
		}
		
		/**
		 *
		 * @public
		 * This function sets Logging level.
		 * This function is called from init() in main.mxml
		 * @param level type of int
		 * @return void
		 *
		 */
		public function setLoggingLevel(level:int):void
		{
			logFileTarget.level=level;
			traceTarget.level=level;
		}
		
		/**
		 *
		 * @public
		 * This function removes the targets and closes Aview_Date.txt.
		 * This function is called from closingapp() in main.mxml
		 *
		 * @return void
		 *
		 */
		public function clear():void
		{
			Log.removeTarget(logFileTarget);
			Log.removeTarget(traceTarget);
			logFileTarget.closeLogFile();
		}
	}
}


