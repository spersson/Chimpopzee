
SOURCES += \
    levelmodel.cpp

HEADERS += \
    levelmodel.h

RESOURCES += \
    resources/resources.qrc

!isEmpty(MEEGO_VERSION_MAJOR){

SOURCES += main-meego.cpp
# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += QtMultimedia

folder_01.source = qml/meego
folder_01.target = qml
DEPLOYMENTFOLDERS += folder_01

include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    chimpopzee.conf \
    qml/meego/gamelogic.js \
    qml/meego/main.qml \
    qml/meego/MenuCard.qml \
    qml/meego/doublelogic.js \
    qml/meego/ImageButton.qml \
    qml/meego/tutorial.js \
    qml/meego/Bubble.qml \
    qml/meego/DoubleBubble.qml \
    qml/meego/LevelButton.qml \


conf_file_01.files = chimpopzee.conf
conf_file_01.path = /usr/share/policy/etc/syspart.conf.d
INSTALLS += conf_file_01

} else:android {

SOURCES += main-android.cpp

folder_01.source = qml/android
folder_01.target = qml
DEPLOYMENTFOLDERS += folder_01

include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

QT += multimedia xml svg

OTHER_FILES += \
    android/src/org/qtproject/qt5/android/bindings/QtActivity.java \
    android/src/org/qtproject/qt5/android/bindings/QtApplication.java \
    android/src/org/kde/necessitas/ministro/IMinistro.aidl \
    android/src/org/kde/necessitas/ministro/IMinistroCallback.aidl \
    android/AndroidManifest.xml \
    android/res/values/libs.xml \
    android/res/values/strings.xml \
    android/res/layout/splash.xml \
    android/res/values-et/strings.xml \
    android/res/values-zh-rCN/strings.xml \
    android/res/values-zh-rTW/strings.xml \
    android/res/values-es/strings.xml \
    android/res/values-nb/strings.xml \
    android/res/values-ms/strings.xml \
    android/res/values-it/strings.xml \
    android/res/values-pl/strings.xml \
    android/res/values-id/strings.xml \
    android/res/values-pt-rBR/strings.xml \
    android/res/values-rs/strings.xml \
    android/res/values-fr/strings.xml \
    android/res/values-ro/strings.xml \
    android/res/values-nl/strings.xml \
    android/res/values-de/strings.xml \
    android/res/values-ja/strings.xml \
    android/res/values-ru/strings.xml \
    android/res/values-fa/strings.xml \
    android/res/values-el/strings.xml \
    android/version.xml \
    qml/android/tutorial.js \
    qml/android/DoubleBubble.qml \
    qml/android/ImageButton.qml \
    qml/android/LevelButton.qml \
    qml/android/MenuCard.qml \
    qml/android/doublelogic.js \
    qml/android/Game.qml \
    qml/android/Bubble.qml \
    qml/android/gamelogic.js \


} else {
SOURCES += main-android.cpp

folder_01.source = qml/android
folder_01.target = qml
DEPLOYMENTFOLDERS += folder_01

include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()


QT += xml svg multimedia

}

