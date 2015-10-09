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
 * File			: ServerVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Server
 * 
 */

package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	import mx.utils.StringUtil;
	
	//The remote java class file which is mapped with this VO class	
	//This class is declared as dynamic, since it uses some of the class 
	//variables which are not therer at the server side.
	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.Server")]
	public dynamic class ServerVO extends Auditable
	{
		// Constants added for aview classroom server
		
		public static var FM_DATA_SERVER_TYPE:Number=0;
		public static var CONTENT_SERVER_TYPE:Number=0;
		public static var FM_VIDEO_PRESENTER_TYPE:Number=0;
		public static var FM_VIDEO_VIEWER_TYPE:Number=0;
		public static var FM_DESKTOP_SHARING_TYPE:Number=0;
		
		// Constants added as part of AVM merge with AVC
		
		public static var MEETING_PRESENTER_VIDEO:Number=0;
		public static var MEETING_COLLABORATION_SERVER:Number=0;
		public static var MEETING_VIEWER_VIDEO:Number=0;
		public static var MEETING_CONTENT_SERVER:Number=0;
		public static var MEETING_DESKTOP_SHARING_SERVER:Number=0;
		
		/**
		 * @public
		 * default constructor
		 */
		
		public function ServerVO()
		{
		
		}
		/**
		 * The server id
		 */
		private var _serverId:Number=0;
		/**
		 * The server name
		 */
		private var _serverName:String=null;
		/**
		 * The server ip
		 */
		private var _serverIp:String=null;
		/**
		 * The server domain
		 */
		private var _serverDomain:String=null;
		/**
		 * The server category
		 */
		private var _serverCategory:String=null;
		/**
		 * The supportsAnimation value
		 */
		private var _supportsAnimation:String=null;
		
		/**
		 * @public
		 * function to get serverCategory
		 *
		 * @return String
		 */
		
		public function get serverCategory():String
		{
			return _serverCategory;
		}
		
		/**
		 * @public
		 * function to set serverCategory
		 * @param value type of String
		 * @return void
		 */
		public function set serverCategory(value:String):void
		{
			_serverCategory=value;
		}
		
		/**
		 * @public
		 * function to get serverId
		 *
		 * @return Number
		 */
		
		public function get serverId():Number
		{
			return _serverId;
		}
		
		/**
		 * @public
		 * function to set serverId
		 * @param serverId type of Number
		 * @return void
		 */
		
		public function set serverId(serverId:Number):void
		{
			this._serverId=serverId;
		}
		
		/**
		 * @public
		 * function to get serverName
		 *
		 * @return String
		 */
		
		public function get serverName():String
		{
			return _serverName;
		}
		
		/**
		 * @public
		 * function to set serverName
		 * @param serverName type of String
		 * @return void
		 */
		
		public function set serverName(serverName:String):void
		{
			this._serverName=serverName;
		}
		
		/**
		 * @public
		 * function to get serverIp
		 *
		 * @return String
		 */
		
		public function get serverIp():String
		{
			//check if the server domain is not null. If so return server domain 
			//as server ip else return server ip itself
			if (_serverDomain != null && StringUtil.trim(_serverDomain).length > 0)
			{
				return _serverDomain;
			}
			else
			{
				return _serverIp;
			}
		}
		
		/**
		 * @public
		 * function to set serverIp
		 * @param serverIp type of String
		 * @return void
		 */
		
		public function set serverIp(serverIp:String):void
		{
			this._serverIp=serverIp;
		}
		
		/**
		 * @public
		 * function to get serverDomain
		 *
		 * @return String
		 */
		
		public function get serverDomain():String
		{
			return _serverDomain;
		}
		
		/**
		 * @public
		 * function to set serverDomain
		 * @param serverDomain type of String
		 * @return void
		 */
		
		public function set serverDomain(serverDomain:String):void
		{
			this._serverDomain=serverDomain;
		}
		
		/**
		 * @public
		 * function to get supportsAnimation
		 *
		 * @return String
		 */
		
		public function get supportsAnimation():String
		{
			return _supportsAnimation;
		}
		
		/**
		 * @public
		 * function to set supportsAnimation
		 * @param value type of String
		 * @return void
		 */
		public function set supportsAnimation(value:String):void
		{
			_supportsAnimation=value;
		}
	
	}
}
