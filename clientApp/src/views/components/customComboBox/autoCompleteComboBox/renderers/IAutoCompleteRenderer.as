////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
package views.components.customComboBox.autoCompleteComboBox.renderers
{
	import mx.core.IDataRenderer;
	
	import spark.components.IItemRenderer;
	
	import views.components.customComboBox.autoCompleteComboBox;
	import views.components.customComboBox.autoCompleteComboBox.AutoCompleteComboBoxLite;
	
	/**
	 * This is an interface that defines the itemRenderer used in the Flextras Spark AutoCompleteComboBox.
	 * 
	 * It defines the typeAheadText value, which can be used for highlighting the typed text in the AutoCompleteComboBox’s itemRenderer.  It also includes a reference to the AutoCompleteComboBox which created the renderer, just in case you need it.
	 * 
	 * Implementing this interface in your itemRenderer is not required, but may be useful if you want to customize the highlight.  
	 * 
	 * 
	 */
	public interface IAutoCompleteRenderer extends IDataRenderer, IItemRenderer
	{
		/**
		 * This is a reference to the AutCompleteComboBox.
		 */
		function get autoCompleteComboBox():AutoCompleteComboBoxLite
		/**
		 * @private 
		 */
		function set autoCompleteComboBox(value:AutoCompleteComboBoxLite):void

		/**
		 * This is a reference to the text that the user typed into the AutoCompleteComboBox.  
		 * The typeAheadText is used for filtering the dataProvider.  
		 * You'll want to reference this value to perform highlighting in your renderer. 
		 * 
		 */
		function get typeAheadText():String

		/**
		 * @private 
		 */
		function set typeAheadText(value:String):void
	
	}
}