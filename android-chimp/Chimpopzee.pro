
SOURCES += \
    main.cpp \
    ../lib/levelmodel.cpp \
    ../lib/highscoresmodel.cpp

HEADERS += \
    ../lib/levelmodel.h \
    ../lib/highscoresmodel.h

RESOURCES += \
    ../resources/resources.qrc

folder_01.source = qml
folder_01.target = ""
DEPLOYMENTFOLDERS += folder_01

include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

QT += multimedia xml svg

OTHER_FILES += \
    qml/tutorial.js \
    qml/doublelogic.js \
    qml/gamelogic.js \
    android/AndroidManifest.xml \
    android/src/org/qtproject/qt5/android/bindings/QtActivity.java

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
