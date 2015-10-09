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
 * File			: BiometricConstants.as
 * Module		: Biometric
 * Developer(s)	: Jerald P
 * Reviewer(s)	: Ramesh Guntha
 */
package edu.amrita.aview.biometric
{
	/**
	 * Biometric constants are declared in this class
	 */
	public class BiometricConstants
	{
		
		public static const DATABASE_NAME:String="aview";
		public static const OK:String="ok";
		public static const CANCEL:String="cancel";
		public static const ENROLL:String="Enroll";
		public static const MATCH:String="Match";
		public static const HTTP:String="http";
		
		public static const REMOVAL:String="Removal";
		public static const TEMPLATE_ID:String="templateID";
		public static const EXTRACTOR:String="Extractor";
		public static const USER_ID:String="userID";
		public static const PROFILER:String="Profiler";
		public static const ENROLLMENT:String="Enrollment";
		public static const REGIST_SUCESSFULLY:String="Registered Successfully";
		public static const ENROLLED_SUCESSFULLY:String="Enrolled Successfully";
		public static const FACE_DETECTION_FAILED:String="Face detection failed. Try again.";
		/**
		 * Maintain the Face count
		 */
		public static var biometricFaceCount:int=0;
		
		public function BiometricConstants()
		{
		}
	}
}
