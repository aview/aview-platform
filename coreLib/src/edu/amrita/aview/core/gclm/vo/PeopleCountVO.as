package edu.amrita.aview.core.gclm.vo
{
	import edu.amrita.aview.core.shared.vo.Auditable;

	[RemoteClass(alias="edu.amrita.aview.gclm.entities.PeopleCount")]
	public class PeopleCountVO extends Auditable
	{
		//The remote java class file which is mapped with this VO class	
		public function PeopleCountVO()
		{
		}
		
		private var _peopleCountId:Number = 0;
		private var _lectureId:Number = 0;
		private var _peopleCountTimestamp:Date = null;
		private var _peopleCountData:String =null;			

		public function get peopleCountId():Number
		{
			return _peopleCountId;
		}

		public function set peopleCountId(value:Number):void
		{
			_peopleCountId = value;
		}

		public function get lectureId():Number
		{
			return _lectureId;
		}

		public function set lectureId(value:Number):void
		{
			_lectureId = value;
		}

		public function get peopleCountTimestamp():Date
		{
			return _peopleCountTimestamp;
		}

		public function set peopleCountTimestamp(value:Date):void
		{
			_peopleCountTimestamp = value;
		}

		public function get peopleCountData():String
		{
			return _peopleCountData;
		}

		public function set peopleCountData(value:String):void
		{
			_peopleCountData = value;
		}


	}
}