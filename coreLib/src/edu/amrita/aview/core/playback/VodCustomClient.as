package edu.amrita.aview.core.playback
{
	public class VodCustomClient
	{
		public function VodCustomClient()
		{
		}
public function onBWDone ( ...args ):void
{

}

public function onLastSecond ( ...args ):void
{

}

  public function onPlayStatus(info:Object):void {
                trace("onPlay");
           }
           public function onMetaData(info:Object):void {
               // trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
           }
           public function onCuePoint(info:Object):void {
                trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
           } 
	}
}