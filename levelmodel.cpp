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

#include <QtCore/QBuffer>
#include <QtCore/QDataStream>
#include <QtCore/QFileInfo>
#include <QtCore/QSettings>

#define COMPLETED_AT_START 9

bool readComplicatedFile(QIODevice &pDevice, QSettings::SettingsMap &pMap) {
	QBuffer lBuffer;
	lBuffer.open(QIODevice::ReadWrite);
	char lByte;
	while(pDevice.getChar(&lByte)) {
		lBuffer.putChar(lByte ^ 85);
	}
	lBuffer.seek(0);
	QDataStream lDataStream(&lBuffer);
	quint32 lVersion;
	lDataStream >> lVersion;
	lDataStream.setVersion(QDataStream::Qt_4_6);
	lDataStream >> pMap;
	return true;
}

bool writeComplicatedFile(QIODevice &pDevice, const QSettings::SettingsMap &pMap) {
	QBuffer lBuffer;
	lBuffer.open(QIODevice::ReadWrite);
	QDataStream lDataStream(&lBuffer);
	lDataStream.setVersion(QDataStream::Qt_4_6);
	lDataStream << (quint32) 1;
	lDataStream << pMap;
	lBuffer.seek(0);
	char lByte;
	while(lBuffer.getChar(&lByte)) {
		pDevice.putChar(lByte ^ 85);
	}
	return true;
}


LevelModel::LevelModel(int pNumLevels, QObject *pParent) :
   QAbstractListModel(pParent), mNumLevels(pNumLevels)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
	setRoleNames(roleNames());
#endif
	const QSettings::Format ComplicatedFormat = QSettings::registerFormat("compl", readComplicatedFile, writeComplicatedFile);
	mSettings = new QSettings(ComplicatedFormat, QSettings::UserScope, QLatin1String("Simon Persson"),
	                          QLatin1String("Chimpopzee"), this);
	QSettings *lSettings = new QSettings(QLatin1String("Simon Persson"), QLatin1String("Chimpachump"));
	QFileInfo lOldIniFile(lSettings->fileName());
	if(lOldIniFile.exists()) {
		int lCompletedCount = lSettings->value(QLatin1String("unlockedLevels")).toInt();
		// version 1.0 did not unlock next level after last level, when levels are added in a later
		// version, first new level is not immideately unlocked even if all previous levels have been passed.
		if(lSettings->value(QString("bestTimes/%1").arg(lCompletedCount), -1).toInt() > -1) {
			lCompletedCount++;
		}
		mSettings->setValue(QLatin1String("completedLevels"), lCompletedCount);
		mSettings->beginGroup("bestTimes");
		lSettings->beginGroup("bestTimes");
		for(int i = 0; i < lCompletedCount; ++i) {
			QString lIndex = QString::number(i);
			mSettings->setValue(lIndex, lSettings->value(lIndex, -1).toInt());
		}
		mSettings->endGroup();
		QFile::remove(lOldIniFile.absoluteFilePath());
		mSettings->sync();
	}
	delete lSettings;
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
		return pIndex.row() > mSettings->value(QLatin1String("completedLevels"), COMPLETED_AT_START).toInt();
	default:
		return QVariant();
	}
}

QHash<int, QByteArray> LevelModel::roleNames() const {
	QHash<int, QByteArray> lRoles;
	lRoles[TimeRole] = "bestTime";
	lRoles[LockedRole] = "locked";
	return lRoles;
}

int LevelModel::completedLevelsCount() {
	return mSettings->value(QLatin1String("completedLevels"), COMPLETED_AT_START).toInt();
}

// parameter pLevel is zero-based, it will be 3 when user just finished level 4.
void LevelModel::registerCompleted(int pLevel) {
	if(pLevel >= completedLevelsCount()) {
		mSettings->setValue(QLatin1String("completedLevels"), pLevel + 1);
		mSettings->sync();
		emit dataChanged(index(pLevel), index(pLevel));
	}
}

bool LevelModel::recordHighscore(int pLevel, int pRemainingTime) {
	QString lKey = QString("bestTimes/%1").arg(pLevel);
	if(mSettings->value(lKey, -1).toInt() < pRemainingTime) {
		mSettings->setValue(lKey, pRemainingTime);
		mSettings->sync();
		emit dataChanged(index(pLevel), index(pLevel));
		return true;
	} else {
		return false;
	}
}

QVariantMap createLevel(int pColumnCount, int pColorCount, int pMonkeyDensity, int pMonkeyValue, int pInitialTime, qreal pFallSpeed) {
	QVariantMap lMap;
	lMap.insert("columnCount", pColumnCount);
	lMap.insert("colorCount", pColorCount);
	lMap.insert("monkeyDensity", pMonkeyDensity);
	lMap.insert("monkeyValue", pMonkeyValue);
	lMap.insert("initialTime", pInitialTime);
	lMap.insert("fallSpeed", pFallSpeed);
	return lMap;
}

void createAllLevels(QVariantList &pLevels) {
	pLevels << createLevel(6, 2, 8, 20, 53, 0.3);
	pLevels << createLevel(6, 2, 9, 20, 51, 0.4);
	pLevels << createLevel(6, 2, 10, 20, 49, 0.5);
	pLevels << createLevel(6, 2, 11, 18, 47, 0.6);
	pLevels << createLevel(6, 2, 12, 17, 45, 0.7);

	pLevels << createLevel(6, 2, 13, 16, 43, 0.7);
	pLevels << createLevel(6, 2, 14, 15, 41, 0.7);
	pLevels << createLevel(6, 2, 15, 14, 39, 0.7);
	pLevels << createLevel(6, 2, 16, 13, 37, 0.7);
	pLevels << createLevel(6, 2, 17, 12, 35, 0.7);

	pLevels << createLevel(6, 3, 18, 15, 44, 0.7);
	pLevels << createLevel(6, 3, 19, 15, 43, 0.7);
	pLevels << createLevel(6, 3, 20, 14, 42, 0.75);
	pLevels << createLevel(6, 3, 21, 14, 41, 0.8);
	pLevels << createLevel(6, 3, 22, 14, 40, 0.85);

	pLevels << createLevel(8, 3, 23, 13, 39, 0.9);
	pLevels << createLevel(8, 3, 24, 13, 38, 0.9);
	pLevels << createLevel(8, 3, 25, 13, 37, 0.95);
	pLevels << createLevel(8, 3, 26, 12, 36, 1.0);
	pLevels << createLevel(8, 3, 27, 12, 35, 1.05);

	pLevels << createLevel(8, 3, 28, 12, 34, 1.1);
	pLevels << createLevel(8, 3, 29, 11, 33, 1.1);
	pLevels << createLevel(8, 3, 30, 11, 32, 1.15);
	pLevels << createLevel(8, 3, 31, 10, 31, 1.15);
	pLevels << createLevel(8, 3, 32, 10, 30, 1.2);

	pLevels << createLevel(8, 4, 33, 15, 39, 0.7);
	pLevels << createLevel(8, 4, 34, 15, 38, 0.7);
	pLevels << createLevel(8, 4, 35, 14, 37, 0.75);
	pLevels << createLevel(8, 4, 36, 14, 36, 0.8);
	pLevels << createLevel(8, 4, 37, 14, 35, 0.85);

	pLevels << createLevel(8, 4, 38, 13, 34, 0.9);
	pLevels << createLevel(8, 4, 39, 13, 33, 0.9);
	pLevels << createLevel(8, 4, 40, 13, 32, 0.95);
	pLevels << createLevel(8, 4, 41, 12, 31, 1.0);
	pLevels << createLevel(8, 4, 42, 12, 30, 1.05);

	pLevels << createLevel(10, 4, 43, 12, 30, 1.1);
	pLevels << createLevel(10, 4, 44, 12, 30, 1.1);
	pLevels << createLevel(10, 4, 45, 12, 30, 1.15);
	pLevels << createLevel(10, 4, 46, 11, 30, 1.15);
	pLevels << createLevel(10, 4, 47, 10, 30, 1.2);

	pLevels << createLevel(10, 5, 40, 15, 38, 0.8);
	pLevels << createLevel(10, 5, 42, 14, 36, 0.8);
	pLevels << createLevel(10, 5, 44, 14, 34, 0.9);
	pLevels << createLevel(10, 5, 46, 13, 32, 0.9);
	pLevels << createLevel(10, 5, 47, 13, 30, 1.0);

	pLevels << createLevel(10, 5, 48, 12, 28, 1.0);
	pLevels << createLevel(10, 5, 49, 12, 28, 1.0);
	pLevels << createLevel(10, 5, 50, 11, 28, 1.0);
	pLevels << createLevel(10, 5, 53, 11, 26, 1.1);
	pLevels << createLevel(10, 5, 55, 10, 26, 1.2);
}

