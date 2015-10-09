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
 * File			: XMLLoadedTree.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 *
 *This component is a reusable custom component for keep the folders and files in a tree manner
 *
 */
//VGCR:-Function Description 
//VGCR:-
package edu.amrita.aview.common.components.fileManager
{
	import edu.amrita.aview.common.components.fileManager.events.DragFinish;
	
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	
	import mx.controls.Alert;
	import mx.controls.Tree;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.mx_internal;
	import mx.effects.Fade;
	import mx.events.DragEvent;
	import mx.events.TreeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.DragManager;
	
	use namespace mx_internal;
	/**
	 *  The XMLLoadedTree component is a custom Tree list.
	 *  You can use for showing files and folders etc.	 
	 *
	 *  <p>The XMLLoadedTree component make additional
	 *  feature ,ie, drag and drop. We can drag a item from this and drop it any
	 *  other components.</p>  
	 *
	 */
	public class XMLLoadedTree extends Tree
	{
		/**
		 * Extended timer class for the open delay.
		 */		
		private var _delayedTimer:DelayedTimer=new DelayedTimer();
		/**
		 * Used to close nodes on delay.
		 */		
		private var _cleanUpDelayedTimer:DelayedTimer=new DelayedTimer();
		/**
		 * Store last folder that the user was over.
		 */		
		private var _lastNodeOver:TreeItemRenderer;
		/**
		 * Fade effect instance for the icon TreeItemRenderer.
		 */		
		private var _treeItemRendererFadeEffect:Fade=new Fade();
		
		
		/**
		 * Will hold the selected node XML details
		 */		
		
		private var selectedNode:XML=new XML();
		
		/**
		 * Keep a list of folders that were open prior to the drag operation so that
		 * we can know not to close them in the restore and close nodes methods.
		 **/
		private var openedFolderHierarchy:Object;
		
		/**
		 * For error log
		 */
		private var log:ILogger=Log.getLogger("aview.common.components.fileManager.XMLLoadedTree.as");
		
		/**
		 * @public 
		 * constructor 
		 *
		 * 
		 * 
		 */
		public function XMLLoadedTree()
		{
			super();
			
			//Drag events
			addEventListener(DragEvent.DRAG_COMPLETE, handleDragComplete);
			addEventListener(DragEvent.DRAG_OVER, handleDragOver);
			addEventListener(DragEvent.DRAG_EXIT, handleDragExit);
			addEventListener(DragEvent.DRAG_START, handleDragStart);
			addEventListener(DragEvent.DRAG_DROP, handleDragDrop);
			
			addEventListener(TreeEvent.ITEM_OPEN, handleItemOpened);
			addEventListener(TreeEvent.ITEM_CLOSE, handleItemClosed);
			
			//key events
			addEventListener(KeyboardEvent.KEY_UP, handleKeyEvents);
			
			_delayedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
			
			this.setStyle("fontSize", 12);
		
		
		}	
		
		/**
		 * When true the node dropped into will be closed on drop complete.
		 **/
		private var _autoCloseOnDrop:Boolean=true;
		
		[Bindable]
		/**
		 * @public
		 * Setting the autoCloseonDrop value 
		 * @param value of type Boolean
		 * @return void
		 */
		public function set autoCloseOnDrop(value:Boolean):void
		{
			_autoCloseOnDrop=value;
		}
		
		/**
		 * @public
		 * For geting the value of autoCloseOnDrop
		 * @return Boolean
		 * 
		 */
		public function get autoCloseOnDrop():Boolean
		{
			return _autoCloseOnDrop;
		}
		
		/**
		 * When true when the user drags outside the control the state is restored
		 * as it was before the drag operation.
		 **/
		private var _autoCloseOnExit:Boolean=true;
		
		[Bindable]
		/**
		 * @public 
		 * @param value of type Boolean
		 * 
		 */
		public function set autoCloseOnExit(value:Boolean):void
		{
			_autoCloseOnExit=value;
		}
		
		/**
		 * @public
		 * 
		 * @return Boolean
		 * 
		 */
		public function get autoCloseOnExit():Boolean
		{
			return _autoCloseOnExit;
		}
		
		/**
		 * When true the node will be closed on dragging out of the current node if;
		 * it was not already open before the drag operation started.
		 *
		 */
		private var _autoCloseOpenNodes:Boolean=true;
		
		[Bindable]
		/**
		 *
		 * @public 
		 * @param value of type Boolean
		 * 
		 */
		public function set autoCloseOpenNodes(value:Boolean):void
		{
			_autoCloseOpenNodes=value;
		}
		
		/**
		 * @public
		 * 
		 * @return Boolean
		 * 
		 */
		public function get autoCloseOpenNodes():Boolean
		{
			return _autoCloseOpenNodes;
		}
		/**
		 * Used to set the timer delay in MS for the closing of the folders.
		 */
		private var _autoCloseTimerMS:Number=100;
		
		[Bindable]
		/**
		 * @public 
		 * @param value of type Number
		 * 
		 */
		public function set autoCloseTimerMS(value:Number):void
		{
			_autoCloseTimerMS;
		}
		
		/**
		 * @public
		 * 
		 * @return Number
		 * 
		 */
		public function get autoCloseTimerMS():Number
		{
			return _autoCloseTimerMS;
		}
		
		/**
		 * Used to set the timer delay in MS for opening folders.
		 */
		private var _autoOpenTimerMS:Number=1000;
		
		[Bindable]
		/**
		 * @public 
		 * @param value of type Number
		 * @result Number
		 */
		public function set autoOpenTimerMS(value:Number):void
		{
			_autoOpenTimerMS=value;
		}
		
		/**
		 * @public
		 * 
		 * @return Number
		 * 
		 */
		public function get autoOpenTimerMS():Number
		{
			return _autoOpenTimerMS;
		}
			
		/**
		 * @private
		 * @param event
		 * The returned dispatched call if delay triggered.
		 * 
		 */
		
		
		private function dispatchDelayedOpen(event:TimerEvent):void
		{
			
			if (autoCloseOpenNodes == true)
			{
				/**
				Stop the indicator if required.
				 */
				if (_treeItemRendererFadeEffect.isPlaying)
				{
					_treeItemRendererFadeEffect.end();
					TreeItemRenderer(itemToItemRenderer(event.currentTarget.item)).alpha=1;
				}
				
				if (dataDescriptor.hasChildren(event.currentTarget.item))
				{
					try
					{
						expandItem(event.currentTarget.item, true, true, true, event);
					}
					catch (err:Error)
					{
						return;
					}
				}
				else
				{
					try
					{
						expandItem(event.currentTarget.item, true, false, true, event);
					}
					catch (err:Error)
					{
						return;
					}
				}
			}
		}		
		
		/**
		 * @private
		 *
		 * stop the currently playing animation
		 * 
		 */
		private function stopAnimation():void
		{
			/**
			 * Stop the indicator if required.
			 */ 
			if (_treeItemRendererFadeEffect.isPlaying)
			{
				_treeItemRendererFadeEffect.end();
				_treeItemRendererFadeEffect.target.alpha=1;
			}
		}
		/**
		 * @private
		 * @param event of type TimerEvent
		 * Start closing the opened nodes.
		 * 
		 */
		private function handleTimerComplete(event:TimerEvent):void
		{
			closeNodes(event.currentTarget.item);
		}
		/**
		 * @private
		 * @param event of type TreeEvent
		 * For each item closed re-curse until all items are closed.
		 * 
		 */
		private function handleItemClosed(event:TreeEvent):void
		{
			if (DragManager.isDragging)
			{
				// AKCR: please use conditional operator here
				if (_lastNodeOver != null)
				{
					closeNodes(_lastNodeOver.data);
				}
				else
				{
					closeNodes(null);
				}
			}
		}
		/**
		 * @private 
		 * @param event of type TreeEvent
		 * Once the animation for opening a node is complete, make the
		 * call to close un wanted open nodes. This will re-curse until all
		 * items are closed.
		 * 
		 */
		private function handleItemOpened(event:TreeEvent):void
		{
			// AKCR: please use conditional operator here
			if (DragManager.isDragging)
			{
				if (_lastNodeOver != null)
				{
					closeNodes(_lastNodeOver.data);
				}
				else
				{
					closeNodes(null);
				}
			}
		}
		/**
		 * @private 
		 * @param item of type Object default value null
		 * Handle the delayed call to close any un wanted nodes.
		 * This is called in a few areas to properly handle the closing.
		 * 
		 */
		private function closeNodes(item:Object=null):void
		{
			
			if (autoCloseOpenNodes == true)
			{
				if (item == null && _lastNodeOver == null)
				{
					_cleanUpDelayedTimer.startDelayedTimer(restoreState, null, null, autoCloseTimerMS, 1, null);
				}
				else
				{
					_cleanUpDelayedTimer.startDelayedTimer(closeOpenNodes, null, null, autoCloseTimerMS, 1, item);
				}
			}
		}
					
		/**
		 * @private 
		 * @param event of type KeyboardEvent
		 * Listen for the spacebar key and open folder if not
		 * already open, then cancel the timer.
		 * 
		 */
		private function handleKeyEvents(event:KeyboardEvent):void
		{
			// AKCR: there is only one case here; need to re-write this method again
			switch (event.keyCode)
			{
				case 32:
					
					if (_lastNodeOver != null)
					{
						
						_delayedTimer.cancelDelayedTimer();
						stopAnimation();
						
						if (dataDescriptor.isBranch(_lastNodeOver.data))
						{
							if (dataDescriptor.hasChildren(_lastNodeOver.data))
							{
								try
								{
									expandItem(_lastNodeOver.data, true, false);
								}
								catch (err:Error)
								{
									break;
								}
							}
							else
							{
								try
								{
									expandItem(_lastNodeOver.data, true, true);
								}
								catch (err:Error)
								{
									break;
								}
							}
							
						}
					}
			}
		}
		
		/**
		 * @private 
		 * @param event of type DragEvent
		 * Handle the drag over trying to make sure we don't do unnecessary calls.
		 * Store the node that the user is currently over for proper close testing.
		 * Dispatch the delayed open call if over a new node.
		 * 
		 * 
		 */
				
		private function handleDragOver(event:DragEvent):void
		{
			
			
			if (autoCloseOpenNodes == false)
			{
				return;
			}
			
			/**
			 *Get the node currently dragging over.
			 */
			var currNodeOver:TreeItemRenderer=TreeItemRenderer(indexToItemRenderer(calculateDropIndex(event)));
			
			if (currNodeOver != null)
			{
				
				/**
				 * If not a branch node exit.
				 */
				if (dataDescriptor.isBranch(currNodeOver.data) != true)
				{
					_delayedTimer.cancelDelayedTimer();
					stopAnimation();
					return;
				}
				
				/**
				 * Cleanup opened nodes.
				 */
				closeNodes(currNodeOver.data);
				
				/**
				 * If the current node is not open then dispatch timer.
				 */
				if (isItemOpen(currNodeOver.data) == false)
				{
					
					/**
					 * If it's already running on the current item avoid a timer reset.
					 */
					if (_delayedTimer.running == true && _delayedTimer.item == currNodeOver.data)
					{
						return;
					}
					else if (_delayedTimer.running == true)
					{
						/**
						 * Clear the current delayed timer.
						 */
						_delayedTimer.cancelDelayedTimer();
						stopAnimation();
					}
					
					/**
					 * Set the local new folder over.
					 */
					_lastNodeOver=currNodeOver;
					
					/**
					 * Create callback.
					 */
					_delayedTimer.startDelayedTimer(dispatchDelayedOpen, null, null, autoOpenTimerMS, 1, currNodeOver.data);
					
					
					
				}
			}
			
			else
			{
				/**
				 * If not over any node cleanup and return.
				 */
				if (_lastNodeOver != null)
				{
					_delayedTimer.cancelDelayedTimer();
					stopAnimation();
					_lastNodeOver=null;
				}
			}
		
		}
				
		/**
		 * @private 
		 * @param event of type DragEvent
		 * Init the start of the drag and grab a open folder stack so we can
		 * compare later when closing, opening, exiting etc.. 
		 */
		private function handleDragStart(event:DragEvent):void
		{
			var currNodeOver:TreeItemRenderer=TreeItemRenderer(indexToItemRenderer(calculateDropIndex(event)));
			if (currNodeOver != null)
			{
				var dragOverXML:XML=currNodeOver.data as XML;
				var rootTag:String=dragOverXML.name().localName.toString();
				var rootLabel:String=dragOverXML.@label;
				DragManager.showFeedback(DragManager.MOVE);
				if (rootTag == "folder" || rootTag == "root" || rootLabel == " - No documents - " || rootLabel == "welcome")
				{
					DragManager.showFeedback(DragManager.NONE);
					event.preventDefault();
					return;
				}
			}
			if (autoCloseOpenNodes == true)
			{
				stopAnimation();
				_delayedTimer.cancelDelayedTimer();
				openedFolderHierarchy=openItems;
			}
		}
		
		/**
		 * @private 
		 * @param event of type DragEvent
		 * Cleanup the drag operation and call restore to set the nodes as
		 * before the drag operation started.
		 * 
		 */
		private function handleDragComplete(event:DragEvent):void
		{
			
			//Get a current state of hierarchy.
			//var currentOpenFolders:Object= this.openItems;
			//event.target.expandItem(currentOpenFolders[3], true, true, true);
			if (!isDropable)
			{
				event.stopImmediatePropagation();
				return;
			}
			
			if (autoCloseOpenNodes == true)
			{
				_delayedTimer.cancelDelayedTimer();
				_lastNodeOver=null;
				
				stopAnimation();
				
				if (_autoCloseOnDrop == true)
				{
					closeNodes(null);
				}
				
			}
		
		}
		
		/**
		 * @private 
		 * Hide the draging notifiaction after drop
		 * @param event of type DragEvent
		 * 
		 */
		private function handleDragExit(event:DragEvent):void
		{
			
			event.target.hideDropFeedback(event);
		/*			_delayedTimer.cancelDelayedTimer();
		_lastNodeOver = null;
		stopAnimation();
		if(_autoCloseOnExit==true){
			closeNodes(null);
		}*/
		}
		/**
		 * @public
		 * @param event of type TimerEvent
		 * Restore tree structure to original state based on the open items
		 * before the drag operation. Called from drag exit and drop complete
		 * to reset original state.
		 * 
		 */
		public function restoreState(event:TimerEvent):void
		{
			
			/**
			 * Back out if state has changed since timer delay setting.
			 */
			if (_lastNodeOver != null)
			{
				return;
			}
			
			/**
			 * Get a current state of hierarchy.
			 */
			var currentOpenFolders:Object=openItems;
			
			for (var i:int=0; i < currentOpenFolders.length; i++)
			{
				// AKCR: please combine the 3 IF conditions, since they dont have an else part
				if (openedFolderHierarchy != null && openedFolderHierarchy.indexOf(currentOpenFolders[i]) == -1)
				{
					if (dataDescriptor.isBranch(currentOpenFolders[i]) == true)
					{
						if (!dataDescriptor.hasChildren(currentOpenFolders[i]))
						{
							
							try
							{
								expandItem(currentOpenFolders[i], false, true, true);
							}
							catch (err:Error)
							{
								break;
							}
							break;
						}
						else
						{
							try
							{
								expandItem(currentOpenFolders[i], false, false, true);
							}
							catch (err:Error)
							{
								break;
							}
							
						}
						
					}
					
				}
			}
		
		
		}
		
		
		/**
		 * @private 
		 * @param event of type TimerEvent
		 * Close all nodes as required, except the current node the user is
		 * dragging over, and only if the node to be closed is not part of the
		 * original open node stack.
		 * 
		 */
		private function closeOpenNodes(event:TimerEvent):void
		{
			
			var parentItems:Object=getParentStack(event.currentTarget.item);
			
			/**
			 * Get a current state of hierarchy.
			 */
			var currentOpenFolders:Object=openItems;
			
			for (var i:int=0; i < currentOpenFolders.length; i++)
			{
				/**
				 * Make sure it was not opened before the drag start 
				 * and the current node that we are dragging over is
				 *  not going to be closed.
				 */
				// AKCR: please combine the 4 IF conditions, there is no else part
				if (openedFolderHierarchy != null && openedFolderHierarchy.indexOf(currentOpenFolders[i]) == -1)
				{
					if (currentOpenFolders[i] != event.currentTarget.item && parentItems.indexOf(currentOpenFolders[i]) == -1)
					{
						/**
						 * Otherwise close the node.
						 */
						if (dataDescriptor.isBranch(currentOpenFolders[i]))
						{
							if (!dataDescriptor.hasChildren(currentOpenFolders[i]))
							{
								try
								{
									expandItem(currentOpenFolders[i], false, true, true);
								}
								catch (err:Error)
								{
									break;
								}
								break;
							}
							else
							{
								try
								{
									expandItem(currentOpenFolders[i], false, false, true);
								}
								catch (err:Error)
								{
									break;
								}
							}
							
							
						}
					}
				}
			}
		
		}
		
		/**
		 * 
		 * @param value of type Object
		 * override the tween end to avoid nasty error on the close of a node
		 * with no children when calling expandItem. without this
		 * sometimes when closeing a node with no children generates an 
		 * Error #1009 in the tree.as error is unhandled so it explodes the app. 
		 * 
		 * 
		 */
		override mx_internal function onTweenEnd(value:Object):void
		{
			
			try
			{
				super.mx_internal::onTweenEnd(value);
			}
			catch (err:Error)
			{
				if(Log.isError()) log.error("Error in onTweenEnd Method:"+ err.getStackTrace());
			}
		}
		
		/**
		 * @private 
		 * @param item of type Object
		 * Returns the stack of parents from a child item.
		 * Note: Stolen from tree code in framwork handy :)!!
		 * @return Array
		 * 
		 */
		private function getParentStack(item:Object):Array
		{
			var stack:Array=[];
			if (item == null)
				return stack;
			var parent:*=getParentItem(item);
			while (parent)
			{
				stack.push(parent);
				parent=getParentItem(parent);
			}
			return stack;
		}
		/**
		 * 
		 */		
		private var isDropable:Boolean=false;
		
		/**
		 * @private 
		 * Handling the drag and drop events
		 * @param event of type DragEvent
		 * 
		 */
		private function handleDragDrop(event:DragEvent):void
		{
			/**
			 * Get the node currently dragging over.
			 */
			event.preventDefault();
			var currNodeOver:TreeItemRenderer=TreeItemRenderer(indexToItemRenderer(calculateDropIndex(event)));
			if (currNodeOver != null)
			{
				event.dragSource.dataForFormat("folder")
				var dragOverXML:XML=currNodeOver.data as XML;
				var rootTag:String=dragOverXML.name().localName.toString();
				var folderType:String=dragOverXML.@type;
				
				if (folderType == "institutes" || folderType == "courses" || folderType == null)
				{
					isDropable=false
					Alert.show("Documents can be moved only to class folders", "INFO", 0, this);
					return;
				}
				else
				{
					isDropable=true;
					var evnt:DragFinish=new DragFinish(DragFinish.DRAG_FINSISHED);
					evnt.dropPath=dragOverXML.@path[0];
					dispatchEvent(evnt);
				}
			}
			else
			{
				Alert.show("Documents can be moved only to class folders", "INFO", 0, this);
				event.preventDefault();
				return;
			}
			
			event.target.hideDropFeedback(event);
		}
	
	
	
	
	}
}

