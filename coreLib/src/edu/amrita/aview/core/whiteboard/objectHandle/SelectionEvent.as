/**
 *  Latest information on this project can be found at http://www.rogue-development.com/objectHandles.html
 *
 *  Copyright (c) 2009 Marc Hughes
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the Software
 *  is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 *  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 *  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 *  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *  See README for more information.
 *
 **/

package edu.amrita.aview.core.whiteboard.objectHandle
{
	import flash.events.Event;
	
	public class SelectionEvent extends Event
	{
		public static const REMOVED_FROM_SELECTION:String="removedFromSelection";
		public static const SELECTION_CLEARED:String="selectionCleared";
		public static const ADDED_TO_SELECTION:String="addedToSelection";
		public static const SELECTED:String="selected";
		public static const HANDLE_MOUSE_DOWN:String="handleMouseDown";
		public static const HANDLE_MOUSE_UP:String="handleMouseUp";
		public var targets:Array=[];
		
		public function SelectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	
	}
}
