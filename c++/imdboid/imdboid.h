// Here we avoid loading the header multiple times
#ifndef IMDBOID_HEADER
#define IMDBOID_HEADER
// We need the Plasma Applet headers
#include <KIcon>

#include <QGraphicsGridLayout>
#include <QGraphicsWidget>
#include <QGraphicsLinearLayout>
#include <Plasma/Applet>
#include <Plasma/Svg>
#include <Plasma/PopupApplet>
#include <Plasma/TextBrowser>
#include "./imdbqueryengine.h"

using namespace Plasma;
namespace Plasma
{
  class BusyWidget;
  class IconWidget;
  class LineEdit;
  class TextBrowser;
  class TabBar;
  class PushButton;
}
class QSizeF;
class KLineEdit;

// Define our plasma Applet
class IMDboid : public Plasma::PopupApplet
{
 Q_OBJECT
 public:
  // Basic Create/Destroy
  IMDboid(QObject *parent, const QVariantList &args);
  ~IMDboid();
       
 private:
  virtual QGraphicsWidget *graphicsWidget();
  QGraphicsWidget         *m_widget;
  QGraphicsLinearLayout   *m_layout;

  QGraphicsWidget         *searchWidget();
  QGraphicsWidget         *m_searchWidget;
  QGraphicsLinearLayout   *m_searchLayout;
  
  QGraphicsWidget         *showWidget();
  QGraphicsWidget         *m_showWidget;
  QGraphicsLinearLayout   *m_showLayout;

  QGraphicsWidget         *busyWidget();
  QGraphicsWidget         *m_busyWidget;
  QGraphicsLinearLayout   *m_busyLayout;
  Plasma::BusyWidget      *m_busy;

  Plasma::TabBar          *tabbar;
  Plasma::TextBrowser     *result;
  Plasma::LineEdit        *searchTerm;
  Plasma::PushButton      *searchButton;
  Plasma::PushButton      *backButton;
  IMDBQueryEngine         *query;

 private slots:
  void dataFetchToUI(QStringList sourceUrl, bool found);
  void getData();
  void switchView();
};

// This is the command that links your applet to the .desktop file
K_EXPORT_PLASMA_APPLET(imdboid, IMDboid)
#endif
