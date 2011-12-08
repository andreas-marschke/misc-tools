/*
  IMDB querying plasmoid
  Copyright (C) 2009-2010  Andreas Marschke


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
#include "imdboid.h"
#include <QPainter>
#include <QFontMetrics>
#include <QFileInfo>
#include <QSizeF>
#include <KLocale>
#include <klineedit.h>
#include <plasma/theme.h>
#include <Plasma/PopupApplet>
#include <plasma/widgets/tabbar.h>
#include <plasma/widgets/busywidget.h>
#include <plasma/widgets/iconwidget.h>
#include <plasma/widgets/label.h>
#include <plasma/widgets/lineedit.h>
#include <plasma/widgets/meter.h>
#include <plasma/widgets/svgwidget.h>
#include <plasma/widgets/tabbar.h>
#include <plasma/widgets/pushbutton.h>
#include <KDebug>

IMDboid::IMDboid(QObject *parent, const QVariantList &args)
  : Plasma::PopupApplet(parent, args) ,
	 m_widget(0) ,
	 m_layout(0) ,
	 m_searchWidget(0) ,
	 m_searchLayout(0) ,
	 m_showWidget(0) ,
	 m_showLayout(0) ,
	 m_busyWidget(0) ,
	 m_busyLayout(0) ,
	 tabbar(0)
{
  kDebug() << "Start Imdboid";
  setBackgroundHints(DefaultBackground);
  setMinimumSize(50,20);
  resize(400, 20);
  setPopupIcon("imdboid");
}

IMDboid::~IMDboid()
{
    if (hasFailedToLaunch()) {
      kDebug() << "Why OH why";
      // Do some cleanup here
    } else {
	// Save settings
    }

}

QGraphicsWidget
*IMDboid::graphicsWidget()
{
  if(!m_widget) {
    m_widget = new QGraphicsWidget(this);
    m_layout = new QGraphicsLinearLayout();

    // Tabbar
    tabbar = new Plasma::TabBar();
    tabbar->setTabBarShown(false);
    tabbar->addTab(QIcon("edit-find"),"Search",searchWidget());
    tabbar->addTab(QIcon("dialog-information"),"Show Details",showWidget());
    tabbar->addTab(QIcon("dialog-information"),"Busy", busyWidget());
    tabbar->setCurrentIndex(0);

    //setup layout
    m_layout->addItem(tabbar);
    m_layout->setOrientation(Qt::Vertical);
    m_layout->setSizePolicy(QSizePolicy::Expanding,QSizePolicy::Expanding,QSizePolicy::ComboBox);

    m_widget->setLayout(m_layout);
    kDebug() << "Main Widget set";
  }
  return m_widget;
}


QGraphicsWidget
*IMDboid::busyWidget()
{
  if( !m_busyWidget ) {
    m_busyWidget = new QGraphicsWidget();
    m_busyLayout = new QGraphicsLinearLayout();
    m_busy = new Plasma::BusyWidget();
    m_busy->setRunning(true);
    m_busyLayout->addItem(m_busy);
    m_busyWidget->setLayout(m_busyLayout);
  }
  return m_busyWidget;
}


void
IMDboid::switchView()
{
  if(tabbar->currentIndex() == 1 ) {
    tabbar->setCurrentIndex(0);
  } else {
    tabbar->setCurrentIndex(1);
  }
}

QGraphicsWidget
*IMDboid::searchWidget()
{
  if(!m_searchWidget) {
    m_searchWidget = new QGraphicsWidget();
    m_searchLayout   = new QGraphicsLinearLayout();

    m_searchLayout->setOrientation(Qt::Horizontal);

    searchTerm = new Plasma::LineEdit();
    searchTerm->setClearButtonShown(true);
    searchTerm->nativeWidget()->setClickMessage("Find movie by title...");

    searchButton = new Plasma::PushButton();
    searchButton->setText("find on IMDb");
    connect(searchButton,SIGNAL(clicked()),this,SLOT(getData()));

    m_searchLayout->addItem(searchTerm);
    m_searchLayout->addItem(searchButton);

    m_searchWidget->setLayout(m_searchLayout);
    kDebug() << "Search done!";
  }
  return m_searchWidget;
}

QGraphicsWidget
*IMDboid::showWidget()
{
  if(!m_showWidget) {
    m_showWidget = new QGraphicsWidget();
    m_showLayout = new QGraphicsLinearLayout();
    m_showLayout->setOrientation(Qt::Vertical);

    result = new Plasma::TextBrowser();
    result->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    result->setStyleSheet("background-color: transparent; bold{ font: bold;}; input{ font: cursiv;};");
    m_showLayout->setStretchFactor(result,1);
    m_showLayout->addItem(result);
    m_showWidget->setLayout(m_showLayout);
    kDebug() << "Show Done!";
  }
  return m_showWidget;
}

void
IMDboid::getData()
{
  //replace by busy widget
  query = new IMDBQueryEngine();
  query->queryIMDB(searchTerm->text());
  tabbar->setCurrentIndex(2);
  connect(query,SIGNAL(dataFetched(QStringList,bool)),
	  this , SLOT(dataFetchToUI(QStringList, bool)));
}

void
IMDboid::dataFetchToUI(QStringList sourceUrl, bool found)
{

  if(found) {
	  result->setText("");
	  result->setText("<img src=\"" +  query->cover() + "\"> <br>"  );
	  result->setText(result->text() +"<bold>Title:</bold> " + query->title() + "<br>" );
	  result->setText(result->text() + "<bold>Genre:</bold> " + query->genreToString(query->genre()) + "<br>");
	  result->setText(result->text() + "<bold>Release Date:</bold> " + query->releaseDate().toString() + "<br>");
	  result->setText(result->text() + "<bold>Country:<bold> " + query->country() + "<br>");
	  result->setText(result->text() + "<bold>Language:</bold> " + query->language() + "<br>");
	  result->setText(result->text() + "<bold>Color:<bold> " +  query->color() + "<br>" );
	  result->setText(result->text() + "<bold>Orig. Aspect Ratio:<bold> " +query->aspectRatio() + "<br>");
	  result->setText(result->text() + "<bold>Locations:</bold> " + query->locations() + "<br>");
	  result->setText(result->text() + "<bold>Company:</bold> " + query->company() + "<br>");
	  result->setText(result->text() + "<bold>Tagline:</bold> " + query->tagline() + "<br>");
	  result->setText(result->text() + "<bold>Production year:</bold> " + query->productionYear() + "<br>");
	  result->setText(result->text() + "<bold>Runtime:</bold> " + query->runtime().toString() + "<br>");
	  tabbar->setCurrentIndex(1);
  } else {
    //sometimes it thinks its not going on so you have to force it into crawling on
    QRegExp regLink("http://www.imdb.com/title/tt[0-9]*/",Qt::CaseSensitive);
    QRegExp regTitle(searchTerm->text(),Qt::CaseInsensitive);
    if(sourceUrl[0].contains(regLink) || sourceUrl[0].contains(regTitle) ) {
      QStringList urlSplit = sourceUrl[0].split(" "); //the first bit is usually the link to the Moviepage
      kDebug() << "Found URL: " << urlSplit[0];
      query->IMDBMovieInfo(QUrl(urlSplit[0]));
    }
  }

}

#include "imdboid.moc"
