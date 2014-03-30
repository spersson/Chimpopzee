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

import QtQuick 1.1

MenuCard {
	anchors.left: parent.right
	Image {
		id: monkeyLogo
		source: "qrc:///bubbles/monkey"
		height: windowHeight*7/24; width: height
		smooth: true
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
		}
	}
	Column {
		anchors {
			top: monkeyLogo.bottom
			left: parent.left; right: parent.right
		}
		spacing: windowHeight/24
		ImageButton {
			source: "qrc:///buttons/startNew"
			onClicked: {
				levelMenu.source = Qt.resolvedUrl("LevelMenu.qml");
				game.state = "Level Menu";
			}
		}
		ImageButton {
			source: "qrc:///buttons/highScores"
			onClicked: {
				if(gHighScoresModel.haveScores) {
					highScoreMenu.source = Qt.resolvedUrl("HighScoreMenu.qml");
					game.state = "Highscore Menu";
				} else {
					submissionMenu.source = Qt.resolvedUrl("SubmissionMenu.qml");
					game.state = "Submission Menu";
				}
			}
		}
		ImageButton {
			source: "qrc:///buttons/tutorial"
			onClicked: {
				tutorialMenu.source = Qt.resolvedUrl("TutorialMenu.qml");
				tutorialMenu.item.pageNumber = 1;
				game.state = "Tutorial Menu"
			}
		}
		ImageButton {
			source: "qrc:///buttons/about"
			onClicked: {
				aboutMenu.source = Qt.resolvedUrl("AboutMenu.qml");
				game.state = "About Menu";
			}
		}
		ImageButton {
			source: "qrc:///buttons/quit"
			onClicked: Qt.quit()
		}
	}
}
