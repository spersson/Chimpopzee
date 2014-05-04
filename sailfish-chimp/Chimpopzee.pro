
TARGET = harbour-chimpopzee

SOURCES += \
	 main.cpp \
	 ../lib/levelmodel.cpp \
	 ../lib/highscoresmodel.cpp

HEADERS += \
	 ../lib/levelmodel.h \
	 ../lib/highscoresmodel.h \
	 platform.h

RESOURCES += \
	 ../resources/resources.qrc

CONFIG += sailfishapp

QT += multimedia xml svg

OTHER_FILES += \
	 qml/tutorial.js \
	 qml/doublelogic.js \
	 qml/gamelogic.js \
	 rpm/Chimpopzee.yaml \
	 harbour-chimpopzee.desktop


