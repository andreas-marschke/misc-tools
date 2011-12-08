using System;
using Qyoto;

namespace Qyoto_Template
{
        class MainClass : QMainWindow
        {
                public static int Main (string[] args)
                {
                        QApplication app = new QApplication(args,true);	
                        QMainWindow window = new QMainWindow();
                        QPushButton button = new QPushButton("Quit",window);
                        window.SetCentralWidget(button);
                        window.Show();
                        Connect(button,SIGNAL("clicked()"),app,SLOT("quit()"));
                        return QApplication.Exec();
                }
        }
}