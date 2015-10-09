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
 * File			: StringUtility.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Veena Gopal K.V
 */
package edu.amrita.aview.common.util
{
	

	//VGCR:-Class Description
	//VGCR:-function Description for all functions
	public class StringUtility
	{
		/**
		 *@public 
		 *Constructor 
		 */
		public function StringUtility()
		{
		}
		
		/**
		 * @public 
		 * @param str of type String
		 * @param trimLength of type int
		 * @return String
		 * 
		 */
		public static function trimString(str:String, trimLength:int):String
		{
			// AKCR: please use a conditional operator
			// AKCR: return (str.length > trimLength) ? str.substr(0, trimLength - 3) + "..." : str; 
			if (str.length > trimLength)
			{
				return str.substr(0, trimLength - 3) + "...";
			}
			else
			{
				return str;
			}
		}
		
		/**
		 * @public 
		 * @param sourceString of type String
		 * @param replacingString of type String
		 * @return String
		 * 
		 */
		public static function replaceSpecialCharecters(sourceString:String, replacingString:String):String
		{
			// AKCR: use an array to avoid duplicate code. for e.g:
			// AKCR: also, move the special patterns array to a global 
			// AKCR: constants file for every other piece of code to reuse 
//			var regExpr:Array = ['/(\/)/g', '/\?/g',... ];
//			for (var i:int = 0 ; i < regExpr.length; i++ ) {
//				sourceString=sourceString.replace(regExpr[i], replacingString);
//			}
			
			/*	var tempString:String=sourceString;
			sourceString=sourceString.replace("/","_").replace("?","_").replace("*","_").replace(":","_").replace("<","_").replace(">","_").replace("\"","_").replace("|","_")
			while(tempString!=sourceString)
			{
			tempString=sourceString
			sourceString=sourceString.replace("/","_").replace("?","_").replace("*","_").replace(":","_").replace("<","_").replace(">","_").replace("\"","_").replace("|","_")
			}*/
			var regExprn:RegExp=/(\/)/g;
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/\?/g;
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/\|/g;
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/:/g;
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/</g;
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/>/g;
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/(\)/g
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/\*/g
			sourceString=sourceString.replace(regExprn, replacingString);
			regExprn=/(")/g
			sourceString=sourceString.replace(regExprn, replacingString);
			return sourceString;
		}
	}
}
