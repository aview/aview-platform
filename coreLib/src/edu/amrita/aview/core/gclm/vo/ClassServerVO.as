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
 * File			: ClassServerVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Class Server
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	//This class is declared as dynamic, since it uses some of the class 
	//variables which are not therer at the server side.
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.ClassServer")]
	public dynamic class ClassServerVO extends Auditable
	{
		/**
		 * @public 
		 * default constructor
		 */
		public function ClassServerVO()
		{
		
		}
		/**
		 * The class server id
		 */
		private var _classServerId:Number=0;
		/**
		 * The server type id
		 */
		private var _serverTypeId:Number=0;
		/**
		 * The server port number
		 */
		private var _serverPort:Number=0;
		/**
		 * The presenter publishing bandwidth in Kbps
		 */
		private var _presenterPublishingBandwidthKbps:Number=0;
		/**
		 * The aview class object
		 */
		private var _aviewClass:ClassVO=null;
		/**
		 * The server object
		 */
		private var _server:ServerVO=null;
		/**
		 * The server type name
		 */
		//non mapped attribute
		private var _serverTypeName:String=null;
		
		/**
		 * @public
		 * function to get class server id
		 *
		 * @return Number
		 */
		public function get classServerId():Number
		{
			return _classServerId;
		}
		
		/**
		 * @public
		 * function to set class server id
		 * @param classServerId type of Number
		 * @return void
		 */
		public function set classServerId(classServerId:Number):void
		{
			this._classServerId=classServerId;
		}
		
		/**
		 * @public
		 * function to get server id
		 *
		 * @return ServerVO
		 */
		public function get server():ServerVO
		{
			return _server;
		}
		
		/**
		 * @public
		 * function to set class server id
		 * @param server type of ServerVO
		 * @return the serverId
		 *
		 */
		public function set server(server:ServerVO):void
		{
			this._server=server;
		}
		
		/**
		 * @public
		 * function to get server type id
		 *
		 * @return Number
		 */
		public function get serverTypeId():Number
		{
			return _serverTypeId;
		}
		
		/**
		 * @public
		 * function to set server Type id
		 * @param serverTypeId type of Number
		 * @return void
		 */
		public function set serverTypeId(serverTypeId:Number):void
		{
			this._serverTypeId=serverTypeId;
		}
		
		/**
		 * @public
		 * function to get server Port
		 *
		 * @return Number
		 */
		public function get serverPort():Number
		{
			return _serverPort;
		}
		
		/**
		 * @public
		 * function to set server Port
		 * @param serverPort type of Number
		 * @return void
		 *
		 */
		public function set serverPort(serverPort:Number):void
		{
			this._serverPort=serverPort;
		}
		
		/**
		 * @public
		 * function to get presenter Publishing Bandwidth
		 *
		 * @return Number
		 */
		public function get presenterPublishingBandwidthKbps():Number
		{
			return _presenterPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to set presenterPublishingBandwidthKbps
		 *  @param presenterPublishingBandwidthKbps type of Number
		 * @return void
		 */
		public function set presenterPublishingBandwidthKbps(presenterPublishingBandwidthKbps:Number):void
		{
			this._presenterPublishingBandwidthKbps=presenterPublishingBandwidthKbps;
		}
		
		/**
		 * @public
		 * function to get aviewClass
		 *
		 * @return ClassVO
		 */
		public function get aviewClass():ClassVO
		{
			return _aviewClass;
		}
		
		/**
		 * @public
		 * function to set aviewClass
		 * @param classvo type of ClassVO
		 * @return void
		 */
		public function set aviewClass(classvo:ClassVO):void
		{
			this._aviewClass=classvo;
		}
		
		/**
		 * @public
		 * function to get serverTypeName
		 *
		 * @return String
		 */
		public function get serverTypeName():String
		{
			return _serverTypeName;
		}
		
		/**
		 * @public
		 * function to set serverTypeName
		 * @param value type of String
		 * @return void
		 */
		public function set serverTypeName(value:String):void
		{
			_serverTypeName=value;
		}
	}
}
