////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: ModuleVO.as
 * Module		: Feedback
 * Developer(s)	: Vijayakumar.R
 * Reviewer(s)	: Deepika CP
 * //ashCR: TODO: what module are we referring to here?
 * value object for the module
 */
package edu.amrita.aview.feedback.vo
{
	import edu.amrita.aview.common.vo.Auditable;
	
	[RemoteClass(alias="edu.amrita.aview.feedback.entities.Module")]
	public class ModuleVO extends Auditable
	{
		public function ModuleVO()
		{
			super();
		}
		
		private var _moduleId:int=0;
		private var _moduleName:String=null;
		
		public function get moduleId():int
		{
			return _moduleId;
		}
		
		public function set moduleId(value:int):void
		{
			_moduleId=value;
		}
		
		public function get moduleName():String
		{
			return _moduleName;
		}
		
		public function set moduleName(value:String):void
		{
			_moduleName=value;
		}
	
	}
}
