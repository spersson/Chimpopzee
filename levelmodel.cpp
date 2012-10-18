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

#include "levelmodel.h"

#include <QtCore/QSettings>

#define UNLOCKED_AT_START 9

LevelModel::LevelModel(int pNumLevels, QObject *pParent) :
   QAbstractListModel(pParent), mNumLevels(pNumLevels)
{
	QHash<int, QByteArray> lRoles;
	lRoles[TimeRole] = "bestTime";
	lRoles[LockedRole] = "locked";
	setRoleNames(lRoles);

	mSettings = new QSettings(QLatin1String("Simon Persson"), QLatin1String("Chimpachump"), this);
}

int LevelModel::rowCount(const QModelIndex &pParent) const {
	Q_UNUSED(pParent)
	return mNumLevels;
}

QVariant LevelModel::data(const QModelIndex &pIndex, int pRole) const {
	switch(pRole) {
	case TimeRole:
		return mSettings->value(QString("bestTimes/%1").arg(pIndex.row()), -1);
	case LockedRole:
		return pIndex.row() > mSettings->value(QLatin1String("unlockedLevels"), UNLOCKED_AT_START).toInt();
	default:
		return QVariant();
	}
}

int LevelModel::unlockedCount() {
	return mSettings->value(QLatin1String("unlockedLevels"), UNLOCKED_AT_START).toInt();
}

void LevelModel::unlock(int pLevel) {
	if(pLevel > mSettings->value(QLatin1String("unlockedLevels"), UNLOCKED_AT_START).toInt()) {
		mSettings->setValue(QLatin1String("unlockedLevels"), pLevel);
		emit dataChanged(index(pLevel), index(pLevel));
	}
}

bool LevelModel::recordHighscore(int pLevel, int pRemainingTime) {
	QString lKey = QString("bestTimes/%1").arg(pLevel);
	if(mSettings->value(lKey, -1).toInt() < pRemainingTime) {
		mSettings->setValue(lKey, pRemainingTime);
		emit dataChanged(index(pLevel), index(pLevel));
		return true;
	} else {
		return false;
	}
}
