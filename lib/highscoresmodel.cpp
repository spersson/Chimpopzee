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

#include "highscoresmodel.h"
#include "levelmodel.h"

#include <QtCore/QBuffer>
#include <QtCore/QDataStream>
#include <QtCore/QFile>
#include <QtCore/QSettings>

LevelModel *LevelHighScoresModel::mLevelModel;
HighScoresModel *LevelHighScoresModel::mHighScoresModel;

LevelHighScoresModel::LevelHighScoresModel(QObject *parent) :
   QAbstractListModel(parent)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
	setRoleNames(roleNames());
#endif
}

QHash<int, QByteArray> LevelHighScoresModel::roleNames() const {
	QHash<int, QByteArray> lRoles;
	lRoles[NameRole] = "name";
	lRoles[TimeRole] = "time";
	lRoles[MyselfRole] = "thisIsMe";
	lRoles[RankRole] = "rank";
	return lRoles;
}

void LevelHighScoresModel::setLevel(int pLevel) {
	if(pLevel < 0 || pLevel >= mHighScoresModel->rowCount(QModelIndex())) {
		return;
	}
	beginResetModel();
	mLevel = pLevel;
	endResetModel();
}

int LevelHighScoresModel::level() {
	return mLevel;
}

void LevelHighScoresModel::registerOtherModels(LevelModel *pLevelModel, HighScoresModel *pHighScoresModel) {
	mLevelModel = pLevelModel;
	mHighScoresModel = pHighScoresModel;
}

int LevelHighScoresModel::rowCount(const QModelIndex &pParent) const {
	Q_UNUSED(pParent)
	const LevelData &lLevelData = mHighScoresModel->getLevel(mLevel);
	if(lLevelData.mOwnRanking >= 0) {
		if(lLevelData.mOwnRanking + 1 > lLevelData.mCount) {
			return lLevelData.mCount + 2;
		} else {
			return lLevelData.mCount;
		}
	} else {
		return lLevelData.mCount;
	}
}

QVariant LevelHighScoresModel::data(const QModelIndex &pIndex, int pRole) const {
	if(!pIndex.isValid()) {
		return QVariant();
	}
	const LevelData &lLevelData = mHighScoresModel->getLevel(mLevel);
	switch(pRole) {
	case NameRole:
		if(pIndex.row() < lLevelData.mCount) {
			return lLevelData.mClientName[pIndex.row()];
		} else if(pIndex.row() == lLevelData.mCount) {
			return QString("...");
		} else if(pIndex.row() == lLevelData.mCount + 1) {
			return mLevelModel->clientName();
		}
		break;
	case TimeRole:
		if(pIndex.row() < lLevelData.mCount) {
			return QString::number(lLevelData.mClientTime[pIndex.row()]);
		} else if(pIndex.row() == lLevelData.mCount) {
			return QString("");
		} else if(pIndex.row() == lLevelData.mCount + 1) {
			if(lLevelData.mType == 1) {
				return QString::number(mLevelModel->totalTime());
			} else {
				return QString::number(mLevelModel->levelRecord(lLevelData.mType - 100));
			}
		}
		break;
	case MyselfRole:
		if(pIndex.row() < lLevelData.mCount) {
			return pIndex.row() == lLevelData.mOwnRanking;
		} else if(pIndex.row() == lLevelData.mCount) {
			return false;
		} else if(pIndex.row() == lLevelData.mCount + 1) {
			return true;
		}
		break;
	case RankRole:
		if(pIndex.row() < lLevelData.mCount) {
			return QString::number(pIndex.row() + 1);
		} else if(pIndex.row() == lLevelData.mCount) {
			return QString("");
		} else if(pIndex.row() == lLevelData.mCount + 1) {
			return QString::number(lLevelData.mOwnRanking + 1);
		}
		break;
	}

	return QVariant();
}


HighScoresModel::HighScoresModel(QObject *pParent) :
   QAbstractListModel(pParent), mHaveScores(false)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
	setRoleNames(roleNames());
#endif
	readScoresFromFile();
}

int HighScoresModel::rowCount(const QModelIndex &pParent) const {
	Q_UNUSED(pParent)
	return mLevelData.count();
}

QVariant HighScoresModel::data(const QModelIndex &pIndex, int pRole) const {
	if(!pIndex.isValid()) {
		return QVariant();
	}
	const LevelData &lLevelData = mLevelData[pIndex.row()];
	switch(pRole) {
	case NameRole:
		if(lLevelData.mType < 100) {
			return QString("Total Time");
		} else {
			return QString("Level %1").arg(lLevelData.mType - 99);
		}
		break;
	}
	return QVariant();
}

QHash<int, QByteArray> HighScoresModel::roleNames() const {
	QHash<int, QByteArray> lRoles;
	lRoles[NameRole] = "levelName";
	return lRoles;
}

const LevelData &HighScoresModel::getLevel(int pLevel) const {
	return mLevelData.at(pLevel);
}

void HighScoresModel::readScoresFromFile() {
	QSettings lSettings(QLatin1String("Simon Persson"), QLatin1String("Chimpopzee"));
	QFile lHighscoreFile(lSettings.fileName().append(".highscores"));
	if(!lHighscoreFile.exists()) {
		return;
	}
	beginResetModel();
	lHighscoreFile.open(QIODevice::ReadOnly);
	QByteArray lByteArray;
	lByteArray.reserve(lHighscoreFile.size());
	QBuffer lBuffer(&lByteArray);
	lBuffer.open(QIODevice::ReadWrite);
	char lByte;
	while(lHighscoreFile.getChar(&lByte)) {
		lBuffer.putChar(lByte ^ 85);
	}
	lHighscoreFile.close();
	lBuffer.reset();

	mLevelData.clear();
	QDataStream lDataStream(&lBuffer);
	while(!lDataStream.atEnd()) {
		LevelData lLevelData;
		QByteArray lUtf8ClientName;
		lDataStream >> lLevelData.mType >> lLevelData.mCount;
		if(lLevelData.mCount > 10) {
			lLevelData.mCount = 10;
		}
		for(int i = 0; i < lLevelData.mCount; ++i) {
			lDataStream >> lUtf8ClientName >> lLevelData.mClientTime[i];
			lLevelData.mClientName[i]	 = QString::fromUtf8(lUtf8ClientName);
		}
		lDataStream >> lLevelData.mOwnRanking;
		mLevelData.append(lLevelData);
	}
	qSort(mLevelData);
	endResetModel();

	if(!mHaveScores) {
		mHaveScores = true;
		emit haveScoresChanged(true);
	}
	emit newHighScoresLoaded();
}

