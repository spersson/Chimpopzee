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

#ifndef LEVELMODEL_H
#define LEVELMODEL_H

#include <QAbstractListModel>

class QIODevice;
class QNetworkAccessManager;
class QNetworkReply;
class QSettings;

class LevelModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int totalTime READ totalTime NOTIFY totalTimeChanged)
public:
	enum LevelRoles {
		TimeRole = Qt::UserRole + 1,
		LockedRole
	};

	explicit LevelModel(int pNumLevels, QNetworkAccessManager *pNetworkManager, QObject *pParent = 0);

	virtual int rowCount(const QModelIndex &pParent) const;
	virtual QVariant data(const QModelIndex &pIndex, int pRole) const;
	virtual QHash<int, QByteArray> roleNames() const;
	Q_INVOKABLE int completedLevelsCount() const;
	Q_INVOKABLE QString clientName() const;
	Q_INVOKABLE int totalTime() const;
	int levelRecord(int pLevel);

signals:
	void totalTimeChanged();
	void postingFailed(QString pMessage);
	void postingSucceded();

public slots:
	void registerCompleted(int pLevel);
	bool recordHighscore(int pLevel, int pRemainingTime);
	void postData(QString pClientName);
	void abortPosting();

protected slots:
	void completePosting();

protected:
	int mNumLevels;
	QSettings *mSettings;
	QNetworkAccessManager *mNetworkManager;
	QNetworkReply *mPostingReply;
};

void createAllLevels(QVariantList &pLevels);

#endif // LEVELMODEL_H
