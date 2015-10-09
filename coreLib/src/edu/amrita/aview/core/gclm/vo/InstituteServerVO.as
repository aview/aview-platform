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
 * File			: InstituteServerVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Institute Server
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	//This class is declared as dynamic, since it uses some of the class 
	//variables which are not therer at the server side.
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.InstituteServer")]
	public dynamic class InstituteServerVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function InstituteServerVO()
		{
		}
		/**
		 * The institute server id
		 */
		private var _instituteServerId:Number=0;
		/**
		 * The server type id
		 */
		private var _serverTypeId:Number=0;
		/**
		 * The institute object
		 */
		private var _institute:InstituteVO=null;
		
		/**
		 * The server object
		 */
		private var _server:ServerVO=null;
		
		/**
		 * The server name
		 */
		//Client only variables
		private var _serverName:String=null;
		
		/**
		 * @public
		 * function to get serverName
		 *
		 * @return String
		 */
		
		public function get serverName():String
		{
			return _server.serverName;
		}
		
		/**
		 * @public
		 * function to set serverName
		 * @param value type of String
		 * @return void
		 */
		public function set serverName(value:String):void
		{
			_serverName=value;
		}
		
		/**
		 * @public
		 * function to get instituteServerId
		 *
		 * @return Number
		 */
		
		public function get instituteServerId():Number
		{
			return _instituteServerId;
		}
		
		/**
		 * @public
		 * function to set instituteServerId
		 * @param instituteServerId type of Number
		 * @return void
		 */
		
		public function set instituteServerId(instituteServerId:Number):void
		{
			this._instituteServerId=instituteServerId;
		}
		
		/**
		 * @public
		 * function to get server
		 *
		 * @return ServerVO
		 */
		
		public function get server():ServerVO
		{
			return _server;
		}
		
		/**
		 * @public
		 * function to set server
		 * @param server type of ServerVO
		 * @return void
		 */
		
		public function set server(server:ServerVO):void
		{
			this._server=server;
		}
		
		/**
		 * @public
		 * function to get serverTypeId
		 *
		 * @return Number
		 */
		
		public function get serverTypeId():Number
		{
			return _serverTypeId;
		}
		
		/**
		 * @public
		 * function to set serverTypeId
		 * @param serverTypeId type of Number
		 * @return void
		 */
		
		public function set serverTypeId(serverTypeId:Number):void
		{
			this._serverTypeId=serverTypeId;
		}
		
		/**
		 * @public
		 * function to get institute
		 *
		 * @return InstituteVO
		 */
		
		public function get institute():InstituteVO
		{
			return this._institute;
		}
		
		/**
		 * @public
		 * function to set institute
		 * @param institute type of InstituteVO
		 * @return void
		 */
		
		public function set institute(institute:InstituteVO):void
		{
			this._institute=institute;
		}
	}
}
