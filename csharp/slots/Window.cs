using System;
using Qyoto;

namespace qyoto_example3
{

	public class Window : QDialog
	{

		public Window () 
		{
			layout = new QVBoxLayout(this);
			browser = new QTextBrowser(this);
			button = new QPushButton("Toggle Text",this);	
			Connect(button,SIGNAL("clicked()"),this,SLOT("toggleText()"));
			toggled = false;
			layout.AddWidget(browser);
			layout.AddWidget(button);
			SetLayout(layout);
		}
		
		//this is how you can declare a QSLOT in C#
		[Q_SLOT("void toggleText()")]
		void toggleText()
		{	
			if(toggled) {
				browser.SetText("<HTML>" +
					"<BODY>" +
					"<H1> Untoggled </H1>" +
					"</BODY>" +
					"</HTML>");
				toggled = false;
			} else {
				browser.SetText("<HTML>" +
					"<BODY>" +
					"<H1> Toggled </H1>" +
					"</BODY>" +
					"</HTML>");
				toggled = true;
			}
		}
		bool toggled;
		private QVBoxLayout layout;
		private QPushButton button;
		private QTextBrowser browser;
	}
}
