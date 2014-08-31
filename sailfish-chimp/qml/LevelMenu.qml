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

MenuCard {
	id: menuCard
	property int largeFontSize: height/24

	Column {
		spacing: windowHeight/44
		anchors {
			topMargin: menuCard.radius * 2/4
			leftMargin: menuCard.radius * 3/4
			rightMargin: menuCard.radius * 3/4
			fill: parent
		}
		Text {
			text: "Select a level"
			font.pixelSize: largeFontSize
			width: parent.width
			horizontalAlignment:	Text.AlignHCenter
		}
		Column {
			clip: true
			width: parent.width
			spacing: -20
			Image {
				width: parent.width; height: 20
				sourceSize.height: height
				source: "qrc:///images/fadedBackground"
				z: 1
			}
			GridView {
				id: levelView
				model: gLevelModel
				width: parent.width
				height: menuCard.height *6/8
				property int  buttonsPerRow: Math.round(10*width/windowHeight)
				cellWidth: width/(buttonsPerRow + 0.1) // ensure not much extra room to the right of buttons
				cellHeight: cellWidth*1.3 // a bit extra margin between rows
				clip: true
				delegate: levelButton
			}
			Image {
				width: parent.width; height: 20
				sourceSize.height: height
				source: "qrc:///images/fadedBackground"
				rotation: 180
				z: 1
			}
		}
		ImageButton {
			id: levelBackButton
			source: "qrc:///buttons/mainMenu"
			onClicked: game.state = "Main Menu";
		}
	}


	Component.onCompleted: {
		levelView.positionViewAtIndex(gLevelModel.completedLevelsCount(), GridView.End);
	}

	Component {
		id: levelButton
		Item {
			width: levelView.cellWidth; height: levelView.cellHeight
			property alias locked: padlock.visible

			MouseArea {
				id: mouseArea
				anchors.fill: parent
				onClicked:if(!model.locked) { game.startLevel(index) }
			}

			Rectangle {
				id: buttonRect
				width: parent.width*3/4; height: width
				anchors.centerIn: parent
				border.width: 2; border.color: locked ? "lightgrey": "black"
				radius: height/6; color: "#f9eec3"
				states: [
					State {
						name: "pressed"
						when: mouseArea.pressed && !locked
						PropertyChanges {
							target: buttonRect
							color: "#c9be93"
						}
					}
				]

				Text {
					text: index + 1
					font.pixelSize: height; font.family: "FreeSans"
					font.bold: true
					color: locked ? "lightgrey": "#534333"
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					width: parent.width
					height: parent.height*2/3
				}

				Text {
					text: bestTime + "s"
					visible: bestTime >= 0
					font.pixelSize: height; font.family: "FreeSans"
					color: "#534333"
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					width: parent.width
					height: parent.height*1/3
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 2
				}
			}

			Image {
				id: padlock
				visible: model.locked
				source: "qrc:///images/padlock"
				height: buttonRect.height*2/3; width: height
				sourceSize.height: height
				smooth: true
				anchors.top: buttonRect.verticalCenter
				anchors.left: buttonRect.horizontalCenter
				opacity: 0.7
			}
		}
	}
}
