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
 * File			: DateFormatterHandler.as
 * Module		: Common
 * Developer(s)	: Sethu Subramanian N
 * Reviewer(s)	: Monisha Mohanan,Veena Gopal K.V
 */
//MMCR:-Function description 
//VGCR:- Variable Description
public var fieldName:String="";

/**
 *
 * @public
 *
 * @param value type of Object
 * @return void
 */
override public function set data(value:Object):void
{
	
	super.data=value;
	if (value == null)
	{
		this.text="";
		return;
	}
	
	try
	{
		this.text=dateFormatter.format(value[fieldName]);
	}
	catch (e:Error)
	{
		this.text="";
	}
}
