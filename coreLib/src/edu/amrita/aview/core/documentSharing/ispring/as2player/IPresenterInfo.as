
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	
	public interface IPresenterInfo
	{
		function get name():String;
		function get title():String;
		function get biographyText():String;
		function get email():String;
		function get webSite():String;
		function hasPhoto():Boolean;
		function get index():Number;
	}
}
