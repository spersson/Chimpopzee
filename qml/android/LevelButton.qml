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

Item {
	width: levelView.cellWidth; height: levelView.cellHeight
	property alias locked: padlock.visible

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked:if(!model.locked) { levelView.startNew(index) }
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
		smooth: true
		anchors.top: buttonRect.verticalCenter
		anchors.left: buttonRect.horizontalCenter
		opacity: 0.7
	}

}
