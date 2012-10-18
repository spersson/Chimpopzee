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

class QSettings;

class LevelModel : public QAbstractListModel
{
	Q_OBJECT
public:
	enum LevelRoles {
		TimeRole = Qt::UserRole + 1,
		LockedRole
	};

	explicit LevelModel(int pNumLevels, QObject *pParent = 0);

	int rowCount(const QModelIndex &pParent) const;
	QVariant data(const QModelIndex &pIndex, int pRole) const;
	Q_INVOKABLE int unlockedCount();

public slots:
	void unlock(int pLevel);
	bool recordHighscore(int pLevel, int pRemainingTime);

private:
	int mNumLevels;
	QSettings *mSettings;
};

#endif // LEVELMODEL_H
