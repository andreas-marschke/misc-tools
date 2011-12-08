/*
 * Description: Get the server address from a mirc list like this
 n0=Ultimate Servers List v5.5 (by sOulbAit)SERVER:k9.chatnet.org:6667GROUP:0
 **/
QString getServerAddress(QFile file)
{
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;
  QString text;
  QTextStream in(&file);
  while (!in.atEnd()) {
    text += in.readLine();
  }
  QString server;
  for (int i = 0; i < text.size(); ++i) {
    if (text.at(i) = QChar(':') ) {
      for(  int s = i++; s < text.size();s++){
	if( text.at(s) == ":" ){
	  break;
	}
	server += text.at(s);	
      }
      break;
    }
  }
  return server;
}
/*
 * Description: Get the server name from a mirc list like this
 n0=Ultimate Servers List v5.5 (by sOulbAit)SERVER:k9.chatnet.org:6667GROUP:0
 **/

QString getServerName(QFile file)
{
  
}
