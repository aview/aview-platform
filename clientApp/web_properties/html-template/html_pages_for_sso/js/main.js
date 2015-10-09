
function registerToAVIEW(e)
{
	if(e.type=="click")
	{
		var dt = new Date().getTime();
		window.location.href='http://aview.in/registration/download.php?nocache=' +dt;
	}
}