////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
package views.components.customComboBox.autoCompleteComboBox
{
		import flash.events.Event;
		
		import mx.events.CollectionEvent;
		import mx.events.CollectionEventKind;
		
		
		// excluded properties 
		[Exclude(name="location", kind="property")] 
		[Exclude(name="oldLocation", kind="property")] 
		[Exclude(name="items", kind="property")] 
		
		/**
		 * 
		 * @private 
		 * This is temporarily left undocumented in the AutoCompleteComboBoxLite component 
		 * 
		 *   The AutoCompleteCollectionEvent represents events associated with the AutoComplete filtering functionality of the 
		 * AutoCompleteComboBox.  
		 *
		 */
		public class AutoCompleteCollectionEvent extends CollectionEvent
		{
	
		    /**
		     *  The <code>AutoCompleteCollectionEvent.AUTOCOMPLETE_DATAPROVIDER_FILTER_BEGIN</code> constant defines the value of the <code>type</code> property of the event object for an event that is dispatched when the <code>AutoCompleteComboBox</code> <code>dataProvider</code> is about to be filtered.  If the <code>filterFunction</code> is null, that means that the dataProvider will be reset	     *
		     *  <p>The properties of the event object have the following values.
		     *  Not all properties are meaningful for all kinds of events.
			 *  See the detailed property descriptions for more information.</p>
			 * 
		     *  <table class="innertable">
		     *     <tr><th>Property</th><th>Value</th></tr>
		     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		     *     <tr><td><code>cancelable</code></td><td>true</td></tr>
		     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		     *       event listener that handles the event. For example, if you use
		     *       <code>myButton.addEventListener()</code> to register an event listener,
		     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		     *     <tr><td><code>filterFunction</code></td><td>The Function that will be used to filter the dataProvider</td></tr>
	 	     *     <tr><td><code>kind</code></td><td>CollectionEventKind.REFRESH</td></tr>
		     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		     *       it is not always the Object listening for the event.
		     *       Use the <code>currentTarget</code> property to always access the
		     *       Object listening for the event.</td></tr>
		     *     <tr><td><code>type</code></td><td>AutoCompleteCollectionEvent.AUTOCOMPLETE_DATAPROVIDER_FILTER_BEGIN</td></tr>
		     *  </table>
		     *
		     *  @eventType autoCompleteDataProviderFilterBegin
			 */
		    public static const AUTOCOMPLETE_DATAPROVIDER_FILTER_BEGIN:String = "autoCompleteDataProviderFilterBegin";
	
	
		    /**
		     *  The <code>AutoCompleteCollectionEvent.AUTOCOMPLETE_DATAPROVIDER_FILTER</code> constant defines the value of the <code>type</code> property of the event object for an event that is dispatched when the filtering for the  <code>AutoCompleteComboBox</code> <code>dataProvider</code> is complete. 
		     * 
		     *  <p>The properties of the event object have the following values.
		     *  Not all properties are meaningful for all kinds of events.
			 *  See the detailed property descriptions for more information.</p>
			 * 
		     *  <table class="innertable">
		     *     <tr><th>Property</th><th>Value</th></tr>
		     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
		     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		     *       event listener that handles the event. For example, if you use
		     *       <code>myButton.addEventListener()</code> to register an event listener,
		     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		     *     <tr><td><code>kind</code></td><td>CollectionEventKind.REFRESH </td></tr>
		     *     <tr><td><code>filterFunction</code></td><td>The function that was used to filter the dataProvider</td></tr>
	         *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		     *       it is not always the Object listening for the event.
		     *       Use the <code>currentTarget</code> property to always access the
		     *       Object listening for the event.</td></tr>
		     *     <tr><td><code>type</code></td><td>AutoCompleteCollectionEvent.AUTOCOMPLETE_DATAPROVIDER_FILTER</td></tr>
		     *  </table>
		     *
		     *  @eventType autoCompleteDataProviderFiltered
			 */
		    public static const AUTOCOMPLETE_DATAPROVIDER_FILTERED:String = "autoCompleteDataProviderFiltered";
	
			/** 
			 * constructor
			 */
			public function AutoCompleteCollectionEvent(type:String, argFilterFunction : Function = null, bubbles:Boolean=false, cancelable:Boolean=false, kind:String=CollectionEventKind.REFRESH, location:int=-1, oldLocation:int=-1, items:Array=null)
			{
				this.filterFunction = argFilterFunction;
				super(type, bubbles, cancelable, kind, location, oldLocation, items);
			}
	
	
		    /**
		    * @private
		    */
			private var _filterFunction : Function ;
		
			/**
			 * The function used to filter the dataProvider for AutoComplete purposes
			 * 
		     *  @default autoCompleteFilter
		     */
			public function get filterFunction (): Function {
				return this._filterFunction;
			}
		
		    /**
		    * @private
		    */
		    public function set filterFunction(value:Function):void{
		    	this._filterFunction = value;
		    }
		
	
		    /**
		     *  @private
		     */
		    override public function clone():Event
		    {  
		        return new AutoCompleteCollectionEvent(type,this.filterFunction, bubbles, cancelable);
		    }
			}
}