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
