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
 * File			: NodeTypeVO.as
 * Module		: GCLM
 * Developer(s)	: Ramesh G, Sethu Subramanian N
 * Reviewer(s)	: Vinod Kumar P
 * 
 * Value Object Class for Node Type
 * 
 */
package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;
	
	//The remote java class file which is mapped with this VO class	
	[RemoteClass(alias="edu.amrita.aview.gclm.entities.NodeType")]
	public class NodeTypeVO extends Auditable
	{
		/**
		 * @public
		 * default constructor
		 */
		
		public function NodeTypeVO()
		{
		}
		/**
		 * The node type id
		 */
		private var _nodeTypeId:Number=0;
		/**
		 * The node type name
		 */
		private var _nodeTypeName:String=null;
		
		/**
		 * @public
		 * function to get nodeTypeId
		 *
		 * @return Number
		 */
		
		public function get nodeTypeId():Number
		{
			return _nodeTypeId;
		}
		
		/**
		 * @public
		 * function to set nodeTypeId
		 * @param nodeTypeId type of Number
		 * @return void
		 */
		
		public function set nodeTypeId(nodeTypeId:Number):void
		{
			this._nodeTypeId=nodeTypeId;
		}
		
		/**
		 * @public
		 * function to get nodeTypeName
		 *
		 * @return String
		 */
		
		public function get nodeTypeName():String
		{
			return _nodeTypeName;
		}
		
		/**
		 * @public
		 * function to set nodeTypeName
		 * @param nodeTypeName type of String
		 * @return void
		 */
		
		public function set nodeTypeName(nodeTypeName:String):void
		{
			this._nodeTypeName=nodeTypeName;
		}
	
	}
}
