// ActionScript file
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
 *
 * File			: SearchController.as
 * Module		: contacts
 * Developer(s)	: Bri.Radha
 * Reviewer(s)	: Veena Gopal K.V
 *
 */
//VGCR:-Function Description for all functions
package edu.amrita.aview.contacts.search
{
	//PNCR: API. changed EventMap point to core/share/eventmap. It will change after create the swc.
	import edu.amrita.aview.common.util.ArrayCollectionUtil;
	import edu.amrita.aview.contacts.events.SearchEvent;
	import edu.amrita.aview.contacts.vo.GroupVO;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.entry.ModuleRO;
	import edu.amrita.aview.core.gclm.GCLMContext;
	import edu.amrita.aview.core.gclm.helper.InstituteHelper;
	import edu.amrita.aview.core.gclm.helper.UserHelper;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.shared.eventmap.EventMap;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;

	/**
	 * 
	 * @public
	 * //PNCR:class description
	 * extends EventDispatcher
	 */
	public class SearchController extends EventDispatcher
	{
		[Bindable]
		private var searchModel:SearchModel = null;
		private var searchView:SearchView = null;
		private var userVO:UserVO = null;
		private var moduleRO:ModuleRO=null;
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.contacts.search.SearchController.as");
		
		/**
		 * @public 
		 * //PNCR: description and function name lowerCamelCase
		 * @param userVO of type UserVO
		 * 
		 */
		public function SearchController(userVO:UserVO,selectedGroup:GroupVO,mro:ModuleRO)
		{
			this.userVO = userVO;
			searchModel=new SearchModel();
			searchModel.selectedGroup=selectedGroup;
			this.moduleRO=mro;
			
		}
		public function init():void
		{
			getInstitutes();
		}
		
		/**
		 * @public 
		 * Function to show search view.
		 * @param callingObject of type DisplayObject
		 * 
		 */
		public function showSearchView(callingObject:DisplayObject):void
		{
			searchView = new SearchView;
			searchView.searchModel=this.searchModel;
			searchView.addEventListener(SearchEvent.SEARCH_EVENT, search);
			searchView.addEventListener(SearchEvent.USERS_SELECTED, onUserSelected);
			PopUpManager.addPopUp(searchView, callingObject);
			PopUpManager.centerPopUp(searchView);
			
		}
		
		/**
		 * @public 
		 * Function to close search view.
		 * @return void
		 */
		public function closeSearchView():void
		{
			PopUpManager.removePopUp(searchView);
			searchModel = null;
			searchView = null;
		}
		
		/**
		 * @private 
		 * Function to search.
		 * @param event of type SearchEvent
		 * 
		 */
		private function search(event:SearchEvent):void
		{
			var userHelper:UserHelper = new UserHelper;
			userHelper.searchActiveUsers(searchModel.fName,null,searchModel.userName,null,null,
																	searchModel.instituteId,searchActiveUsersResultHandler,null,
																	0,searchModel.email, searchModel.phoneNumber,0,searchModel.stateId);
		}
		
		/**
		 * @public
		 * Result handler function for searchActiveUsers.
		 *
		 * Set the user status,display search component to show the results.
		 *
		 * @param activeUserCollection of type ArrayCollection.
		 */
		public function searchActiveUsersResultHandler(users:ArrayCollection):void
		{
			//remove the current user if he exists in the list
			for (var i:int = 0; i < users.length; i++)
			{
				if (users[i].userId == userVO.userId)
				{
					users.removeItemAt(i);
				}
			}
			if (users.length == 0)
			{
				Alert.show("No such user exists.", "Information");
				searchView.btnSearch.enabled=true;
				return;
			}
			searchModel.users = users;
			createSearchResultComponent();			
		}
		private function createSearchResultComponent():void
		{
			var searchResultViewController:SearchResultController=new SearchResultController(userVO,moduleRO);
			var searchResultView:SearchResultView=searchResultViewController.getSearchResultView();	
			searchResultView.addEventListener(CloseEvent.CLOSE,onCloseSearchResultView);
			searchResultViewController.getSearchResultModel().setGroupUsers(searchModel.users,searchModel.selectedGroup);
			searchResultViewController.getOnlineUsers();
			PopUpManager.addPopUp(searchResultView,this.searchView.parent,true);
			PopUpManager.centerPopUp(searchResultView);
		}
		
		private function onCloseSearchResultView(event:CloseEvent):void
		{
			searchView.btnSearch.enabled=true;
		}
		/**
		 * @private 
		 * @param event of type SearchEvent
		 */
		private function onUserSelected(event:SearchEvent):void
		{
			closeSearchView();
			this.dispatchEvent(new SearchEvent(SearchEvent.USERS_SELECTED, event.data));
		}
		private function getInstitutes():void
		{
			var instituteHelper:InstituteHelper = new edu.amrita.aview.core.gclm.helper.InstituteHelper;
			if(userVO.role == Constants.ADMIN_TYPE)
			{
				instituteHelper.getAllCourseOfferingInstitutesForAdmin(userVO.userId,getAllCourseOfferingInstitutesResultHandler);
			}
			else
			{
				instituteHelper.getAllCourseOfferingInstitutes(getAllCourseOfferingInstitutesResultHandler);
			}
		}
		
		public function getAllCourseOfferingInstitutesResultHandler(institutes : ArrayCollection) : void
		{
			if(institutes != null)
			{
				ArrayCollectionUtil.sortData(institutes,"instituteName",false, true);
				GCLMContext.allCourseOfferingInstitutesAC = institutes;
				if(Log.isInfo()) log.info("getAllCourseOfferingInstitutesResultHandler After array collection:"+new Date());
			}
			else
			{
				Alert.show("Error occured while getting the institutes","Error");
			}
		}
	}
}