
SOURCES += \
    main.cpp \
	 ../lib/levelmodel.cpp \
	 ../lib/highscoresmodel.cpp

HEADERS += \
	 ../lib/levelmodel.h \
	 ../lib/highscoresmodel.h

RESOURCES += \
	 ../resources/resources.qrc

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += QtMultimedia

folder_01.source = qml
folder_01.target = ""
DEPLOYMENTFOLDERS += folder_01

include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
	 qml/gamelogic.js \
	 qml/doublelogic.js \
	 qml/tutorial.js \
	 qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
	 chimpopzee.conf

conf_file_01.files = chimpopzee.conf
conf_file_01.path = /usr/share/policy/etc/syspart.conf.d
INSTALLS += conf_file_01
