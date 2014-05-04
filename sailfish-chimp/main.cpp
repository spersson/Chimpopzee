/***************************************************************************
 *   Copyright (C) by Simon Persson                                        *
 *   simonpersson1@gmail.com                                               *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include <QtCore/QVariant>
#include <QtGui/QGuiApplication>
#include <QtQml/QtQml>
#include <QtQuick/QQuickView>
#include <QtNetwork/QNetworkAccessManager>

#include <sailfishapp.h>
#include "../lib/levelmodel.h"
#include "../lib/highscoresmodel.h"
#include "platform.h"

Q_DECL_EXPORT int main(int argc, char *argv[]) {
	QGuiApplication *lApplication = SailfishApp::application(argc, argv);
	QQuickView *lView = SailfishApp::createView();

	QVariantList lLevelList;
	createAllLevels(lLevelList);
	lView->rootContext()->setContextProperty(QStringLiteral("gLevels"), lLevelList);

	QNetworkAccessManager lNetworkManager;
	LevelModel *lLevelModel = new LevelModel(lLevelList.count(), &lNetworkManager, lApplication);
	lView->rootContext()->setContextProperty(QStringLiteral("gLevelModel"), lLevelModel);

	HighScoresModel *lHighScoresModel = new HighScoresModel(lApplication);
	lView->rootContext()->setContextProperty(QStringLiteral("gHighScoresModel"), lHighScoresModel);

	QObject::connect(lLevelModel, SIGNAL(postingSucceded()), lHighScoresModel, SLOT(readScoresFromFile()));
	QObject::connect(lView->engine(), SIGNAL(quit()), lApplication, SLOT(quit()));

	qmlRegisterType<LevelHighScoresModel>("harbour.chimpopzee.ChimpModels", 1, 0, "LevelHighScoreModel");
	LevelHighScoresModel::registerOtherModels(lLevelModel, lHighScoresModel);

	Platform lPlatform(lView);
	lView->rootContext()->setContextProperty(QStringLiteral("gPlatform"), &lPlatform);


	lView->setSource(SailfishApp::pathTo(QStringLiteral("qml/Root.qml")));
	lView->showFullScreen();

	return lApplication->exec();
}
