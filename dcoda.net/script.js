

/*
window.onload = init_ie6_li;

function init_ie6_li() 
{
	var isIE6 = navigator.userAgent.toLowerCase().indexOf("msie") != -1
	&& navigator.userAgent.toLowerCase().indexOf("msie 7") == -1
	&& navigator.userAgent.toLowerCase().indexOf("msie 8") == -1;

	if(!isIE6)
		return;

	var top_menu = document.getElementById("con_menu");
	var LI_Array = top_menu.getElementsByTagName("li");

	var LI_IE = [];

	for(var i=0; i < LI_Array.length; i++)
	{
		if(LI_Array[i].className.search(/ie_li/i) != -1)
		{
			LI_IE.push(LI_Array[i]);	
		}
	}

	for(var i=0; i < LI_IE.length; i++)
	{
			LI_IE[i].onmouseover = function () { 
					var subLIArray = this.getElementsByTagName("li");;
					for(var j=0; j < subLIArray.length; j++) 
					{
						if(subLIArray[j].className.search(/drop/i) != -1)
						{
							subLIArray[j].style.display = "block";
						}
						else if(subLIArray[j].className.search(/main/i) != -1)
						{
							subLIArray[j].style.backgroundColor = "#d7d7d7";

						}

					}
				};

			LI_IE[i].onmouseout = function () { 
					var subLIArray = this.getElementsByTagName("li");	
					for(var k=0; k < subLIArray.length; k++) 
					{
						if(subLIArray[k].className.search(/drop/i) != -1)
						{
							subLIArray[k].style.display = "none";

						}
						else if(subLIArray[k].className.search(/main/i) != -1)
						{
							subLIArray[k].style.backgroundColor = "#c7c7c7";

						}

					}
				}; 
	}
}


*/
//Above commented out no longer needed
// for old IE browser
//
function home()
{
   document.getElementById("about").style.display = 'none';
   document.getElementById("home").style.display = 'block';
}

function about()
{
   document.getElementById("home").style.display = 'none';
   document.getElementById("about").style.display = 'block';
}

function studies()
{
   document.getElementById("home").style.display = 'none';
   document.getElementById("about").style.display = 'none';
   document.getElementById("studies").style.display = 'block';
}
