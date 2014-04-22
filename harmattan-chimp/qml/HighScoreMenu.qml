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
import ChimpModels 1.0

MenuCard {
	id: menuCard
	property int largeFontSize: height/44
	property int smallFontSize: height/55
	Component {
		id: recordDelegate
		Row {
			anchors {
				left: parent.left
				right: parent.right
				margins: smallFontSize/2
			}

			spacing: width * 0.02
			Text {
				text: rank
				width: parent.width * 0.05
				font {
					bold: thisIsMe
					pixelSize: smallFontSize
				}
				horizontalAlignment: Text.AlignRight
			}
			Text {
				text: name
				width: parent.width * 0.76
				font {
					bold: thisIsMe
					pixelSize: smallFontSize
				}
			}
			Text {
				text: time
				width: parent.width * 0.15
				font {
					bold: thisIsMe
					pixelSize: smallFontSize
				}
				horizontalAlignment: Text.AlignRight
			}
		}
	}

	Component {
		id: levelDelegate
		Rectangle {
			id: levelWrapper
			radius: windowHeight/160
			width: levelList.width - 4
			height: levelNameText.height + smallFontSize + (ListView.isCurrentItem ? recordsLoader.height + smallFontSize / 2: 0)
			x: 2
			border.width: 2
			border.color: "#534333"
			color: "#f9eec3"
			Text {
				id: levelNameText
				text: levelName
				font.pixelSize: largeFontSize
				anchors {
					top: parent.top
					left: parent.left
					right: parent.right
					margins: smallFontSize / 2
				}
			}
			Text {
				text: "Time (s)"
				horizontalAlignment: Text.AlignRight
				font.pixelSize: smallFontSize
				visible: levelWrapper.ListView.isCurrentItem
				anchors {
					left: parent.left
					right: parent.right
					bottom: levelNameText.bottom
					rightMargin: smallFontSize / 2
				}
			}
			Loader {
				id: recordsLoader
				anchors {
					top: levelNameText.bottom
					left: parent.left
					right: parent.right
					margins: smallFontSize / 2
				}
				Component {
					id: recordListDelegate
					ListView {
						id: recordList
						boundsBehavior: Flickable.StopAtBounds
						height: childrenRect.height
						contentHeight: contentItem.childrenRect.height
						model: LevelHighScoreModel {
							level: index
						}
						delegate: recordDelegate
					}
				}
				sourceComponent: levelWrapper.ListView.isCurrentItem ? recordListDelegate: undefined
			}
			MouseArea {
				anchors.fill: parent
				onClicked: levelWrapper.ListView.view.currentIndex = index
			}
		}
	}

	Column {
		spacing: windowHeight/24
		anchors {
			topMargin: menuCard.radius * 3/4
			leftMargin: menuCard.radius * 3/4
			rightMargin: menuCard.radius * 3/4
			fill: parent
		}
		Column {
			clip: true
			width: parent.width
			spacing: -largeFontSize
			Image {
				width: parent.width
				height: largeFontSize
				source: "qrc:///images/fadedBackground"
				z: 1
			}
			ListView {
				id: levelList
				model: gHighScoresModel
				width: parent.width
				height: menuCard.height *5/8
				spacing: smallFontSize/3
				delegate: levelDelegate
				header: Item { height: largeFontSize } // keep the end of the list from being displayed in the faded zone
				footer: Item { height: largeFontSize }
			}
			Image {
				width: parent.width
				height: largeFontSize
				source: "qrc:///images/fadedBackground"
				rotation: 180
				z: 1
			}
		}
		ImageButton {
			source: "qrc:///buttons/refresh"
			onClicked: {
				submissionMenu.source = Qt.resolvedUrl("SubmissionMenu.qml");
				game.state = "Submission Menu"
			}
		}
		ImageButton {
			source: "qrc:///buttons/mainMenu"
			onClicked: game.state = "Main Menu"
		}
	}
}
