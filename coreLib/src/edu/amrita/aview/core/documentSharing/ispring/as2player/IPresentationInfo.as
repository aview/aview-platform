
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	
	public interface IPresentationInfo
	{
		function get title():String;
		function get slides():ISlidesCollection;
		function get slideWidth():Number;
		function get slideHeight():Number;
		function hasPresenter():Boolean;
		function get presenterInfo():IPresenterInfo;
		function get frameRate():Number;
		function get duration():Number;
		function hasCompanyInfo():Boolean;
		function get companyInfo():ICompanyInfo;
		function hasReferences():Boolean;
		function get references():IReferencesCollection;
		function get visibleDuration():Number;
		function get presenters():IPresentersCollection;
	}
}
