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

#ifndef HIGHSCORESMODEL_H
#define HIGHSCORESMODEL_H

#include <QAbstractListModel>

class LevelModel;

struct LevelData {
	quint32 mType;
	qint32 mCount;
	QString mClientName[10];
	qint32 mClientTime[10];
	qint32 mOwnRanking;
	bool operator<(const LevelData &pOther) const {
		return mType < pOther.mType;
	}
};

class HighScoresModel: public QAbstractListModel {
	Q_OBJECT
	Q_PROPERTY(bool haveScores READ haveScores NOTIFY haveScoresChanged)

public:
	enum HighScoreRole {
		NameRole = Qt::UserRole + 1
	};

	explicit HighScoresModel(QObject *pParent = 0);
	virtual int rowCount(const QModelIndex &pParent) const;
	virtual QVariant data(const QModelIndex &pIndex, int pRole) const;
	virtual QHash<int, QByteArray> roleNames() const;

	const LevelData &getLevel(int pLevel) const;
	bool haveScores() const {
		return mHaveScores;
	}

public slots:
	void readScoresFromFile();

signals:
	void haveScoresChanged(bool pHaveScores);
	void newHighScoresLoaded();

protected:
	QList<LevelData> mLevelData;
	bool mHaveScores;
};


class LevelHighScoresModel: public QAbstractListModel {
	Q_OBJECT
	Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged)
public:
	enum RecordRole {
		NameRole = Qt::UserRole + 1,
		TimeRole,
		MyselfRole,
		RankRole
	};

	explicit LevelHighScoresModel(QObject *parent = 0);
	virtual int rowCount(const QModelIndex &pParent) const;
	virtual QVariant data(const QModelIndex &pIndex, int pRole) const;
	virtual QHash<int, QByteArray> roleNames() const;

	void setLevel(int pLevel);
	int level();

	static void registerOtherModels(LevelModel *pLevelModel, HighScoresModel *pHighScoresModel);

signals:
	void levelChanged();

protected:
	int mLevel;
	static LevelModel *mLevelModel;
	static HighScoresModel *mHighScoresModel;
};

#endif // HIGHSCORESMODEL_H
