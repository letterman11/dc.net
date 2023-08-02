function show(arg)
{
	if(arg == 'home')
	{
		document.getElementById("center_center_con").style.display='block';
		document.getElementById("center_center_con2").style.display='none';
		document.getElementById("center_center_con3").style.display='none';
	}
	else if(arg == 'about')
	{

		document.getElementById("center_center_con").style.display='none';
		document.getElementById("center_center_con2").style.display='block';
		document.getElementById("center_center_con3").style.display='none';
	}
	else if(arg == 'contact')
	{
		document.getElementById("center_center_con").style.display='none';
		document.getElementById("center_center_con2").style.display='none';
		document.getElementById("center_center_con3").style.display='block';
	}

}
