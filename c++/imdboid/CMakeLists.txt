# Project Needs a name ofcourse
project(plasma-imdboid)

# Find the required Libaries
find_package(KDE4 REQUIRED)
find_package(Qt4 COMPONENTS QtCore REQUIRED )
include(KDE4Defaults)

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include(${QT_USE_FILE})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_INCLUDES}
   ${QT_INCLUDES}
   ${QT_QTCORE_INCLUDE_DIR}
   ${QT_QTNETWORK_INCLUDE_DIR}
   )

# We add our source code here
set(imdboid_SRCS
  imdboid.cpp
  imdbqueryengine.cpp
  )

# Now make sure all files get to the right place
kde4_add_plugin(plasma_applet_imdboid ${imdboid_SRCS})
target_link_libraries(plasma_applet_imdboid
		      ${KDE4_PLASMA_LIBS}
		     ${QT_QTCORE_LIBRARY}
		     ${KDE4_KDEUI_LIBS}
		     ${QT_LIBRARIES}
		     ${QT_QTNETWORK_LIBRARY})
PROJECT(imdboid)

add_subdirectory(icons)
install(TARGETS plasma_applet_imdboid
	DESTINATION ${PLUGIN_INSTALL_DIR})

install(FILES plasma-applet-imdboid.desktop
	DESTINATION ${SERVICES_INSTALL_DIR})

kde4_install_icons( ${ICON_INSTALL_DIR} )
