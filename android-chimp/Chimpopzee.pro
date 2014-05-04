
SOURCES += \
    main.cpp \
    ../lib/levelmodel.cpp \
    ../lib/highscoresmodel.cpp

HEADERS += \
    ../lib/levelmodel.h \
    ../lib/highscoresmodel.h

RESOURCES += \
    ../resources/resources.qrc \
    qml/qml.qrc

QT += qml quick multimedia xml svg

OTHER_FILES += \
    android/AndroidManifest.xml

# Default rules for deployment.
include(deployment.pri)


ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
