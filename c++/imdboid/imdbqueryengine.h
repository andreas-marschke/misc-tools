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

#ifndef  IMDBQUERYENGINE_H
#define  IMDBQUERYENGINE_H

#include <QHttp>
#include <QFile>
#include <QBuffer>
#include <QUrl>
#include <QDate>
#include <QTime>


/**
 * This class is for getting data from imdb.com for a particular film
 * Following things can be gathered with this class:
 * - Image of the title
 * - Rating (Votes)
 * - name of the director
 * - Movie Title
 * - Genre
 * - Release Date
 * - Country
 * - Language
 * - Runtime
 * - Color e.g. Color or Black/White
 * - original Aspect Ratio
 * - Filming Locations
 * - Company e.g. "Jerry Bruckheimer Films"
 * - Tagline
 * - Production Year
 * A basic examble for getting IMDB data
 * @code
 * IMDBQueryEngine *query = new IMDBQueryEngine();
 * query->queryIMDB("Harry Potter");
 * connect(query,SIGNAL(dataFetched(QStringList sourceUrl, bool found)),
 *                      this,SLOT(dataFetchToUI(QStringList sourceUrl, bool found)));
 * //in dataFetchToUI() @see dataFetched()
 * if(found) {
 * QLabel videoTitle = new QLabel(query->title());
 * }
 * /@code
 *
 * @short gather movie information from IMDB
 * @author Philipp Schuler
 * @author Andreas Marschke <xxtjaxx@gmail.com>
 *
 * @version 1.0.5~beta
 **/

class IMDBQueryEngine : public QHttp
{
  Q_OBJECT
    public:
      IMDBQueryEngine(void);
      ~IMDBQueryEngine(void);

      /**
       * @info this is the list of genres possible
       **/
      enum Genre {
	Action       =  0,
	Adventure    =  1,
	Animation    =  2,
	Biography    =  3,
	Comedy       =  4,
	Crime        =  5,
	Documentary  =  6,
	Drama        =  7,
	Family       =  8,
	Fantasy      =  9,
	FilmNoir     = 10,
	GameShow     = 11,
	History      = 12,
	Horror       = 13,
	Music        = 14,
	Musical      = 15,
	Mystery      = 16,
	News         = 17,
	RealityTV    = 18,
	Romance      = 19,
	SciFi        = 20,
	Short        = 21,
	Sport        = 22,
	TalkShow     = 23,
	Thriller     = 24,
	War          = 25,
	Western      = 26,
	Unknown      = 27
      };


      /**
       * initialize searching IMDB for information
       * if the information is fetched and parsed it
       * sends the @signal dataFetched() and further progress can made.
       **/
      void queryIMDB(QString query); //e.g. "harry potter"

      /**
       * get IMDB data from custom URL such as
       * QUrl("http://www.imdb.com/title/tt0436339/")
       **/
      void IMDBMovieInfo(QUrl);

      /**
       * Original Query
       **/
      QString imdbQueryString();

      /**
       * @info Rating (Votes) e.g. "7.5/10 (45,348 votes)"
       **/
      qreal rating();

      /**
       * @info Director
       **/
      QString director();

      /**
       * @info Movie Title
       **/
      QString title();

      /**
       * Conversions for Genre to either String or int
       **/
      QString genreToString( Genre genre_ );
      int genreToInt(Genre genre_ );

      /**
       * Returns IMDBquery::Genre of @param QString genre.
       * If @param localized is true uses localized string.
       **/
      Genre genreFromString(QString genre , bool localized );

      /**
       * @info genre
       **/
      Genre genre();
      /**
       * @info Release Date
       **/
      QDate releaseDate();
      /**
       * @info Country of creation
       **/
      QString country();

      /**
       * @info original Language
       **/
      QString language();

      /**
       * @info Runtime
      **/
      QTime runtime();

      /**
       * @info Color e.g. Color or Black/White
       **/
      QString color();

      /**
       * @info Aspect Ratio
       **/
      QString aspectRatio();

      /**
       * @info Filming Locations
       **/
      QString locations();

      /**
       * @info Company e.g. "Jerry Bruckheimer Films"
       **/
      QString company();

      /**
       * @info Plot Tagline
       **/
      QString tagline();

      /**
       * @info Prod Year
       **/
      QString productionYear();

      /**
       * @info returns the QFile of the downloaded  image file
       **/
      QString cover();

    private:
      QBuffer *page;
      int requestId;
      bool moviePage;
      QString m_query;

      qreal m_rating;
      QString m_director;
      QString m_title;
      Genre  m_genre;
      QDate m_releaseDate;
      QString m_country;
      QString m_language;
      QTime m_runtime;
      QString m_color;
      QString m_aspectRatio;
      QString m_locations;
      QString m_company;
      QString m_tagLine;
      QString m_productionYear;
      QUrl sourceUrl;
      QFile *m_cover;
      QStringList m_imagesFromSite;
      void noMoviePage(QByteArray data);
      void getMoviePage(QByteArray data);
      QBuffer *image_data;

      QHttp *picturefetch;
      QMap<QString,QObject> m_imdbMap;

  private slots:
      void requestFinished(int,bool);
      void coverdownloaded(int id , bool error);
    signals:
      /**
       * @info dataFetched is send when all informations are fetched.
       * if the site and data was found return true and empty @param sourceUrl
       * if no website was found return false and a @param QStringList of all search
       * result URL's.
      **/
      void dataFetched(QStringList sourceUrl, bool found);

};

#endif
