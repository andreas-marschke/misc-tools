/*
  IMDB querying class
  Copyright (C) 2009  Philipp Schuler
  Copyright (C) 2009  Andreas Marschke

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#include "imdbqueryengine.h"
#include <KLocale>
#include <KDebug>
#include <QtCore/QRegExp>
#include <QFile>

IMDBQueryEngine::IMDBQueryEngine(void)
{
	connect(this,SIGNAL(requestFinished(int,bool)),this,SLOT(requestFinished(int,bool)));
}

IMDBQueryEngine::~IMDBQueryEngine(void)
{
}

void
IMDBQueryEngine::requestFinished(int id, bool error)
{
  Q_UNUSED(error);
  if(id!=requestId) return;
  QByteArray data(page->data());
  page->close();

  if(!moviePage)
    {
      noMoviePage(data);
    }
  else //film seite auslesen
    {
      getMoviePage(data);
    }

}

void
IMDBQueryEngine::noMoviePage(QByteArray data)
{
  //QRegExp regtest("canonical\" href=\"(http://www.imdb.com/title/.*/)\" />",Qt::CaseInsensitive);
  /*if(regtest.indexIn(data)>-1)
    {
    results.append(regtest.cap(1));
    this->results = results;
    return;
    }*/
  //Search result Seite nach link/title/year crawlen

  QRegExp reg("find-title-\\d/.*/images/b.gif\\?link=/title/(.*)/';\">(.*)</a>(.*)<",Qt::CaseInsensitive);
  reg.setMinimal(true);
  int pos = reg.indexIn(data);
  QStringList urls;
  while(pos>-1)
    {
      urls.append(QString("http://www.imdb.com/title/%1/ %2 %3").arg(reg.cap(1)).arg(reg.cap(2)).arg(reg.cap(3)).remove("&#x22;"));
      data = data.right(data.size()-(pos+reg.matchedLength()));
      pos = reg.indexIn(data);

    }
  emit dataFetched(urls,false);
}


void
IMDBQueryEngine::getMoviePage(QByteArray data)
{

  //ratings/votes auslesen
  QRegExp reg("<b>(\\d.\\d)/10</b>.*ratings.*>(.*)</a>");
  reg.setMinimal(true);
  int pos = reg.indexIn(data);
  m_rating = qreal(QString(QString("%1/10 (%2)").arg(reg.cap(1)).arg(reg.cap(2))).toFloat());

  //director auslesen
  reg.setPattern("<h5>Director:</h5>.*;\">(.*)</a>");
  pos = reg.indexIn(data);
  m_director = QString(reg.cap(1).simplified());

  //filmtitel auslesen
  reg.setPattern("<title>(.*).*\\(");
  pos = reg.indexIn(data);
  m_title= QString(reg.cap(1));

  //genre auslesen
  reg.setPattern("<h5>Genre:</h5>(.*)<a class");
  pos = reg.indexIn(data);
  QString res = reg.cap(1);
  QString tmp;
  reg.setPattern("<a href=\"/Sections/Genres.*/\">(.*)</a>");
  while((pos = reg.indexIn(res)) > -1)
    {
      tmp += " / "+reg.cap(1);
      res = res.right(res.length()-res.indexOf("</a>")-4);
    }
  tmp = tmp.right(tmp.length()-3);
  m_genre = genreFromString( QString(tmp.simplified()), false);

  //release date auslesen
  reg.setPattern("<h5>Release Date:</h5>.*>(.*)\\(.*<a class");
  pos = reg.indexIn(data);
  m_releaseDate = QDate().fromString(reg.cap(1).simplified(),
				     "d' 'MMMM' 'yyyy");

  //country auslesen
  reg.setPattern("<h5>Country:</h5>.*>(.*)</div>");
  pos = reg.indexIn(data);
  res = reg.cap(1);
  tmp.clear();
  reg.setPattern("<a href=\"/Sections/Countries.*/\">(.*)</a>");
  while((pos = reg.indexIn(res)) > -1 )
    {
      tmp += " / "+reg.cap(1);
      res = res.right(res.length()-res.indexOf("</a>")-4);
    }
  tmp = tmp.right(tmp.length()-3);
  m_country = QString(tmp.simplified());

  //language auslesen
  reg.setPattern("<h5>Language:</h5>.*>(.*)</div>");
  pos = reg.indexIn(data);
  res = reg.cap(1);
  tmp.clear();
  reg.setPattern("<a href=\"/Sections/Languages.*/\">(.*)</a>");
  while((pos = reg.indexIn(res)) >-1) 	{
    tmp += " / "+reg.cap(1);
    res = res.right(res.length()-res.indexOf("</a>")-4);
  }
  tmp = tmp.right(tmp.length()-3);
  m_language = QString(tmp.simplified());

  //runtime auslesen
  reg.setPattern("<h5>Runtime:</h5>.*>(.*)</div>");
  pos = reg.indexIn(data);
  m_runtime = QTime().addSecs(QString(reg.cap(1).simplified()).split(" ")[0].toInt()*60);

  //color auslesen
  reg.setPattern("<h5>Color:</h5>.*>.*>(.*)</a>");
  pos = reg.indexIn(data);
  m_color = reg.cap(1).simplified();

  //aspect ratio auslesen
  reg.setPattern("<h5>Aspect Ratio:</h5>.*>(.*)<a");
  pos = reg.indexIn(data);
  m_aspectRatio = reg.cap(1).simplified();

  //filming lcoation auslesen
  reg.setPattern("<h5>Filming Locations:</h5>.*>.*>(.*)</a");
  pos = reg.indexIn(data);
  m_locations = reg.cap(1).simplified();

  //company auslesen
  reg.setPattern("<h5>Company:</h5>.*>.*>(.*)</a");
  pos = reg.indexIn(data);
  m_company = reg.cap(1).simplified();

  //plot auslesen
  reg.setPattern("<h5>Plot:</h5>.*>(.*)<");
  pos = reg.indexIn(data);
  m_tagLine = reg.cap(1);

  //prod year
  reg.setPattern("<title>.*\\((.*)\\)");
  pos = reg.indexIn(data);
  m_productionYear = reg.cap(1);

  /**
   * Image of the title cover
   * for more images maybe interesting:
   * http://www.imdb.com/title/tt0099685/mediaindex
   **/

  QStringList line;
  reg.setPattern( QString("\"poster\" href=\"/rg/action-box-title/primary-photo/media/rm[0-9]*/tt[0-9]*\" title=\"[a-zA-Z0-9\\ ]*\"><img border=\"0\" alt=\"[a-zA-Z0-9\\ ]*\" title=\"[a-zA-Z0-9\ ]*\" src=\"http://ia.media-imdb.com/images/[A-Z]/([A-Za-z0-9@._]*|[A-Za-z0-9@.]*|[A-Za-z0-9._]*).jpg\" /></a>") );
  while( ( pos = reg.indexIn(data,pos))  != -1 ) {
    kDebug() << reg.capturedTexts();
    pos += reg.matchedLength();
    line << reg.capturedTexts();
  }
  QStringList images;
  pos = 0;
  QRegExp Url_("http://ia.media-imdb.com/images/[A-Z]/[A-Za-z0-9@._]*.jpg",Qt::CaseInsensitive);
  while( (pos = Url_.indexIn(line.join("|"),pos)) != -1 ) {
      kDebug() << Url_.capturedTexts();
      images << Url_.capturedTexts();
      pos += Url_.matchedLength();
  }

  QUrl myPicture;
  if(images.size() == 1 ) {
    myPicture = QUrl(images.join(""));
    picturefetch = new QHttp(myPicture.host(),80);
    connect(picturefetch,SIGNAL(requestFinished(int,bool)),this,SLOT(coverdownload(int,bool)));
    image_data = new QBuffer();
    requestId = picturefetch->get(myPicture, image_data);
  }

  emit dataFetched(QStringList(""),true);
}


void
IMDBQueryEngine::queryIMDB(QString imdbquery)
{
  page = new QBuffer();
  page->open(QBuffer::ReadWrite);

  QUrl url;
  url = QUrl((QString("http://www.imdb.com/find?q=%1").arg(imdbquery)));
  moviePage = false;
  this->setHost(url.host());
  requestId = this->get(url.path()+"?"+url.encodedQuery(),page);
}

void
IMDBQueryEngine::IMDBMovieInfo (QUrl url)
{
  page = new QBuffer();
  page->open(QBuffer::ReadWrite);
  this->setHost(url.host());
  moviePage = true;
  requestId = this->get(url.path(),page);
  emit requestFinished(requestId,moviePage);
}

void
IMDBQueryEngine::coverdownloaded(int id , bool error)
{
  Q_UNUSED(error);
  if(id!=requestId) return;
  QByteArray data(image_data->data());
  image_data->close();
  m_cover = new QFile("file.jpg");
  QDataStream out(m_cover);
  out << image_data;
  m_cover->close();
}

qreal
IMDBQueryEngine::rating()
{
  return m_rating;
}

QString
IMDBQueryEngine::director()
{
  return m_director;
}

QString
IMDBQueryEngine::title()
{
  return m_title;
}

QString
IMDBQueryEngine::genreToString( Genre genre )
{
  if ( genre == IMDBQueryEngine::Action) {
    return i18n("Action");
  } else if ( genre ==  IMDBQueryEngine::Adventure ) {
    return i18n("Adventure");
  }else if ( genre ==  IMDBQueryEngine::Animation ) {
    return i18n("Animation");
  }else if ( genre ==  IMDBQueryEngine::Biography ) {
    return i18n("Biography");
  }else if ( genre ==  IMDBQueryEngine::Comedy ) {
    return i18n("Comedy");
  }else if ( genre ==  IMDBQueryEngine::Crime ) {
    return i18n("Crime");
  }else if ( genre ==  IMDBQueryEngine::Documentary ) {
    return i18n("Documentary");
  }else if ( genre ==  IMDBQueryEngine::Drama ) {
    return i18n("Drama");
  }else if ( genre ==  IMDBQueryEngine::Family ) {
    return i18n("Family");
  }else if ( genre ==  IMDBQueryEngine::Fantasy ) {
    return i18n("Fantasy");
  }else if ( genre ==  IMDBQueryEngine::FilmNoir ) {
    return i18n("Film-Noir");
  }else if ( genre ==  IMDBQueryEngine::GameShow ) {
    return i18n("Game-Show");
  }else if ( genre ==  IMDBQueryEngine::History ) {
    return i18n("History");
  }else if ( genre ==  IMDBQueryEngine::Horror ) {
    return i18n("Horror");
  }else if ( genre ==  IMDBQueryEngine::Music ) {
    return i18n("Music");
  }else if ( genre ==  IMDBQueryEngine::Musical ) {
    return i18n("Musical");
  }else if ( genre ==  IMDBQueryEngine::Mystery ) {
    return i18n("Mystery");
  }else if ( genre ==  IMDBQueryEngine::News ) {
    return i18n("News");
  }else if ( genre ==  IMDBQueryEngine::RealityTV ) {
    return i18n("Reality-TV");
  }else if ( genre ==  IMDBQueryEngine::Romance ) {
    return i18n("Romance");
  }else if ( genre ==  IMDBQueryEngine::SciFi ) {
    return i18n("Sci-Fi");
  }else if ( genre ==  IMDBQueryEngine::Short ) {
    return i18n("Short");
  }else if ( genre ==  IMDBQueryEngine::Sport ) {
    return i18n("Sport");
  }else if ( genre ==  IMDBQueryEngine::TalkShow ) {
    return i18n("Talk-Show");
  }else if ( genre ==  IMDBQueryEngine::Thriller ) {
    return i18n("Thriller");
  }else if ( genre ==  IMDBQueryEngine::War ) {
    return i18n("War");
  }else if ( genre ==  IMDBQueryEngine::Western ) {
    return i18n("Western");
  } else {
    return i18n("Unknown");
  }
}

int
IMDBQueryEngine::genreToInt(Genre genre)
{
  if ( genre == IMDBQueryEngine::Action) {
    return 0 ;
  } else if ( genre ==  IMDBQueryEngine::Adventure ) {
    return 1;
  }else if ( genre ==  IMDBQueryEngine::Animation ) {
    return 2;
  }else if ( genre ==  IMDBQueryEngine::Biography ) {
    return 3;
  }else if ( genre ==  IMDBQueryEngine::Comedy ) {
    return 4;
  }else if ( genre ==  IMDBQueryEngine::Crime ) {
    return 5;
  }else if ( genre ==  IMDBQueryEngine::Documentary ) {
    return 6;
  }else if ( genre ==  IMDBQueryEngine::Drama ) {
    return 7;
  }else if ( genre ==  IMDBQueryEngine::Family ) {
    return 8;
  }else if ( genre ==  IMDBQueryEngine::Fantasy ) {
    return 9;
  }else if ( genre ==  IMDBQueryEngine::FilmNoir ) {
    return 10;
  }else if ( genre ==  IMDBQueryEngine::GameShow ) {
    return 11;
  }else if ( genre ==  IMDBQueryEngine::History ) {
    return 12;
  }else if ( genre ==  IMDBQueryEngine::Horror ) {
    return 13;
  }else if ( genre ==  IMDBQueryEngine::Music ) {
    return 14;
  }else if ( genre ==  IMDBQueryEngine::Musical ) {
    return 15;
  }else if ( genre ==  IMDBQueryEngine::Mystery ) {
    return 16;
  }else if ( genre ==  IMDBQueryEngine::News ) {
    return 17;
  }else if ( genre ==  IMDBQueryEngine::RealityTV ) {
    return 18;
  }else if ( genre ==  IMDBQueryEngine::Romance ) {
    return 19;
  }else if ( genre ==  IMDBQueryEngine::SciFi ) {
    return 20;
  }else if ( genre ==  IMDBQueryEngine::Short ) {
    return 21;
  }else if ( genre ==  IMDBQueryEngine::Sport ) {
    return 22;
  }else if ( genre ==  IMDBQueryEngine::TalkShow ) {
    return 23;
  }else if ( genre ==  IMDBQueryEngine::Thriller ) {
    return 24;
  }else if ( genre ==  IMDBQueryEngine::War ) {
    return 25;
  }else if ( genre ==  IMDBQueryEngine::Western ) {
    return 26;
  } else {
    return 27;
  }
}

IMDBQueryEngine::Genre
IMDBQueryEngine::genreFromString(QString genre , bool localized )
{
  if(localized){
    if ( genre.contains(i18n("Action")) ) {
      return IMDBQueryEngine::Action;
    }else if ( genre.contains(i18n("Adventure")) ) {
      return IMDBQueryEngine::Adventure ;
    }else if ( genre.contains(i18n("Animation")) ) {
      return IMDBQueryEngine::Animation;
    }else if ( genre.contains(i18n("Biography")) ) {
      return IMDBQueryEngine::Biography;
    }else if ( genre.contains(i18n("Comedy")) ) {
      return IMDBQueryEngine::Comedy ;
    }else if ( genre.contains(i18n("Crime")) ) {
      return IMDBQueryEngine::Crime;
    }else if ( genre.contains(i18n("Documentary")) ) {
      return IMDBQueryEngine::Documentary;
    }else if ( genre.contains(i18n("Drama")) ) {
      return IMDBQueryEngine::Drama;
    }else if ( genre.contains(i18n("Family"))  ) {
      return IMDBQueryEngine::Family;
    }else if ( genre.contains(i18n("Fantasy")) ) {
      return IMDBQueryEngine::Fantasy;
    }else if ( genre.contains(i18n("Film-Noir")) ) {
      return IMDBQueryEngine::FilmNoir;
    }else if ( genre.contains(i18n("Game-Show")) ) {
      return  IMDBQueryEngine::GameShow;
    }else if ( genre.contains(i18n("History")) ) {
      return IMDBQueryEngine::History ;
    }else if ( genre.contains(i18n("Horror")) ) {
      return IMDBQueryEngine::Horror;
    }else if ( genre.contains(i18n("Music")) ) {
      return  IMDBQueryEngine::Music;
    }else if ( genre.contains(i18n("Musical")) ) {
      return IMDBQueryEngine::Musical;
    }else if ( genre.contains(i18n("Mystery")) ) {
      return IMDBQueryEngine::Mystery ;
    }else if ( genre.contains(i18n("News")) ) {
      return IMDBQueryEngine::News;
    }else if ( genre.contains(i18n("Reality-TV")) ) {
      return IMDBQueryEngine::RealityTV;
    }else if ( genre.contains(i18n("Romance")) ) {
      return  IMDBQueryEngine::Romance;
    }else if ( genre.contains(i18n("Sci-Fi")) ) {
      return IMDBQueryEngine::SciFi;
    }else if ( genre.contains(i18n("Short")) ) {
      return IMDBQueryEngine::Short;
    }else if ( genre.contains(i18n("Sport")) ) {
      return IMDBQueryEngine::Sport;
    }else if ( genre.contains(i18n("Talk-Show")) ) {
      return IMDBQueryEngine::TalkShow;
    }else if ( genre.contains(i18n("Thriller")) ) {
      return IMDBQueryEngine::Thriller ;
    }else if ( genre.contains(i18n("War")) ) {
      return IMDBQueryEngine::War;
    }else if ( genre.contains(i18n("Western")) ) {
      return IMDBQueryEngine::Western;
    } else {
      return IMDBQueryEngine::Unknown;
    }
  } else {
    if ( genre.contains("Action") ) {
      return IMDBQueryEngine::Action;
    }else if ( genre.contains("Adventure") ) {
      return IMDBQueryEngine::Adventure ;
    }else if ( genre.contains("Animation") ) {
      return IMDBQueryEngine::Animation;
    }else if ( genre.contains("Biography") ) {
      return IMDBQueryEngine::Biography;
    }else if ( genre.contains("Comedy") ) {
      return IMDBQueryEngine::Comedy ;
    }else if ( genre.contains("Crime") ) {
      return IMDBQueryEngine::Crime;
    }else if ( genre.contains("Documentary") ) {
      return IMDBQueryEngine::Documentary;
    }else if ( genre.contains("Drama")) {
      return IMDBQueryEngine::Drama;
    }else if ( genre.contains("Family")) {
      return IMDBQueryEngine::Family;
    }else if ( genre.contains("Fantasy")) {
      return IMDBQueryEngine::Fantasy;
    }else if ( genre.contains("Film-Noir")) {
      return IMDBQueryEngine::FilmNoir;
    }else if ( genre.contains("Game-Show")) {
      return  IMDBQueryEngine::GameShow;
    }else if ( genre.contains("History")) {
      return IMDBQueryEngine::History ;
    }else if ( genre.contains("Horror")) {
      return IMDBQueryEngine::Horror;
    }else if ( genre.contains("Music")) {
      return  IMDBQueryEngine::Music;
    }else if ( genre.contains("Musical")) {
      return IMDBQueryEngine::Musical;
    }else if ( genre.contains("Mystery")) {
      return IMDBQueryEngine::Mystery ;
    }else if ( genre.contains("News")) {
      return IMDBQueryEngine::News;
    }else if ( genre.contains("Reality-TV")) {
      return IMDBQueryEngine::RealityTV;
    }else if ( genre.contains("Romance")) {
      return  IMDBQueryEngine::Romance;
    }else if ( genre.contains("Sci-Fi")) {
      return IMDBQueryEngine::SciFi;
    }else if ( genre.contains("Short")) {
      return IMDBQueryEngine::Short;
    }else if ( genre.contains("Sport")) {
      return IMDBQueryEngine::Sport;
    }else if ( genre.contains( "Talk-Show")) {
      return IMDBQueryEngine::TalkShow;
    }else if ( genre.contains("Thriller")) {
      return IMDBQueryEngine::Thriller ;
      }else if ( genre.contains("War") ) {
      return IMDBQueryEngine::War;
      }else if ( genre.contains("Western") ) {
      return IMDBQueryEngine::Western;
    } else {
      return IMDBQueryEngine::Unknown;
    }
  }
}
IMDBQueryEngine::Genre
IMDBQueryEngine::genre()
{
  return m_genre;
}

QDate
IMDBQueryEngine::releaseDate()
{
  return m_releaseDate;
}

QString
IMDBQueryEngine::country()
{
  return m_country;
}

QString
IMDBQueryEngine::language()
{
  return m_language;
}

QTime
IMDBQueryEngine::runtime()
{
  return m_runtime;
}

QString
IMDBQueryEngine::color()
{
  return m_color;
}

QString
IMDBQueryEngine::aspectRatio()
{
  return m_aspectRatio;
}

QString
IMDBQueryEngine::locations()
{
  return m_locations;
}

QString
IMDBQueryEngine::company()
{
  return m_company;
}

QString
IMDBQueryEngine::tagline()
{
  return m_tagLine;
}

QString
IMDBQueryEngine::productionYear()
{
  return m_productionYear;
}

QString
IMDBQueryEngine::cover()
{
	return m_cover->fileName();
}



#include "moc_imdbqueryengine.cpp"
