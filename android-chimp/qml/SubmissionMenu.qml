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

import QtQuick 2.0
import QtQuick.Controls 1.0

MenuCard {
	id: menuCard
	property int fontPixelSize: height/32
	MouseArea {
		anchors.fill: parent
		onClicked: submitButton.focus = true;
	}

	Column {
		anchors {
			fill: parent
			margins: windowHeight/16
		}
		spacing: windowHeight/16

		Text {
			anchors.horizontalCenter: parent.horizontalCenter
			width: parent.width
			text: "Upload your scores and see how you compare to my wife Wendy, she's very good at this game. " +
			      "When your scores are uploaded you will also receive the latest online scores."
			font.pixelSize: fontPixelSize
			horizontalAlignment: Text.AlignJustify
			wrapMode: Text.Wrap
		}

		Column {
			width: parent.width
			spacing: windowHeight/72
			TextField {
				id: clientName
				width: parent.width
				anchors.horizontalCenter: parent.horizontalCenter
				text: gLevelModel.clientName();
				placeholderText: "Please enter your name..."
				font.pixelSize: fontPixelSize
				inputMethodHints: Qt.ImhNoPredictiveText
				Keys.onReturnPressed: {
					submitButton.focus = true;
				}
			}
			Text {
				text: "Your total time:\n" + gLevelModel.totalTime() + " seconds";
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: fontPixelSize
				wrapMode: Text.Wrap
			}
			Text {
				id: result
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: fontPixelSize
				wrapMode: Text.Wrap
			}
		}

		ImageButton {
			id: submitButton
			source: gHighScoresModel.haveScores ? "qrc:///buttons/refresh": "qrc:///buttons/submit"
			onClicked: {
				if(clientName.text.length > 0) {
					menuCard.state = "Sending";
					gLevelModel.postData(clientName.text);
				} else {
					result.text = "You have to provide a name!";
				}
			}
		}

		ImageButton {
			id: returnButton
			source: "qrc:///buttons/cancel"
			onClicked: {
				if(gHighScoresModel.haveScores) {
					highScoreMenu.source = Qt.resolvedUrl("HighScoreMenu.qml");
					game.state = "Highscore Menu";
				} else {
					game.state = "Main Menu";
				}
				menuCard.state = "Aborted"
				gLevelModel.abortPosting();
			}
		}
	}

	Connections {
		target: gLevelModel
		onPostingSucceded: {
			menuCard.state = "Completed";
			result.text = "Success!"
		}
		onPostingFailed: {
			menuCard.state = "Completed";
			result.text = "Error: " + pMessage
		}
	}

	Connections {
		target: gHighScoresModel
		onNewHighScoresLoaded: {
			if(menuCard.state !== "Aborted") {
				highScoreMenu.source = Qt.resolvedUrl("HighScoreMenu.qml");
				game.state = "Highscore Menu";
			}
		}
	}

	property int dotCount: 1
	Timer {
		repeat: true
		interval: 300
		running: menuCard.state === "Sending";
		onTriggered: {
			if(dotCount === 1) {
				result.text = "Sending.";
			} else if(dotCount === 2) {
				result.text = "Sending..";
			} else {
				result.text = "Sending...";
			}
			dotCount = (dotCount + 1) % 3;
		}
	}
}
