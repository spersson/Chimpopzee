#ifndef PLATFORM_H
#define PLATFORM_H

#include <QWindow>
#include <QDebug>

class Platform: public QObject {
	Q_OBJECT
	Q_PROPERTY(bool allowSwipe READ allowSwipe WRITE setAllowSwipe NOTIFY allowSwipeChanged)

public:
	Platform(QWindow *pWindow) : mWindow(pWindow) {}
	bool allowSwipe() const {
		return !(mWindow->flags() & Qt::WindowOverridesSystemGestures);
	}

public slots:
	void setAllowSwipe(bool pAllowSwipe) {
		if (allowSwipe() != pAllowSwipe) {
			if(pAllowSwipe) {
				mWindow->setFlags(mWindow->flags() & ~Qt::WindowOverridesSystemGestures);
//				qDebug() <<"cleared override flag!";
			} else {
				mWindow->setFlags(mWindow->flags() | Qt::WindowOverridesSystemGestures);
//				qDebug() <<"set override flag!";
			}
			emit allowSwipeChanged(pAllowSwipe);
		}
	}

signals:
	void allowSwipeChanged(bool pAllowed);

private:
	QWindow *mWindow;
};

#endif // PLATFORM_H
