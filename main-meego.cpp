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
#include <QtGui/QApplication>
#include <QtDeclarative>

#include "qmlapplicationviewer.h"
#include "levelmodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[]) {
	QScopedPointer<QApplication> app(createApplication(argc, argv));
	QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

	QVariantList lLevelList;
	createAllLevels(lLevelList);
	viewer->rootContext()->setContextProperty(QLatin1String("gLevels"), lLevelList);

	LevelModel *lLevelModel = new LevelModel(lLevelList.count());
	viewer->rootContext()->setContextProperty(QLatin1String("gLevelModel"), lLevelModel);
	viewer->setMainQmlFile(QLatin1String("qml/meego/Game.qml"));
	viewer->showExpanded();

	return app->exec();
}
