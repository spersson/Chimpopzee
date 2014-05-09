
TARGET = harbour-chimpopzee

CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp
INCLUDEPATH += /usr/include/sailfishapp

SOURCES += \
	 main.cpp \
	 ../lib/levelmodel.cpp \
	 ../lib/highscoresmodel.cpp

HEADERS += \
	 ../lib/levelmodel.h \
	 ../lib/highscoresmodel.h \
	 platform.h

RESOURCES += \
	 ../resources/resources.qrc \
         qml/qml.qrc

QT += qml quick multimedia

OTHER_FILES += \
	 rpm/Chimpopzee.yaml \
	 harbour-chimpopzee.desktop

target.path = /usr/bin

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications

icon.files = $${TARGET}.png
icon.path = /usr/share/icons/hicolor/86x86/apps

INSTALLS += target desktop icon

