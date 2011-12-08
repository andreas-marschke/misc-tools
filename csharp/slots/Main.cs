using System;
using Qyoto;
namespace qyoto_example3
{
	class MainClass
	{
		public static int Main (string[] args)
		{
			QApplication app = new QApplication(args,true);
			Window w = new Window();
			w.Show();
			return QApplication.Exec();
		}
	}
}
