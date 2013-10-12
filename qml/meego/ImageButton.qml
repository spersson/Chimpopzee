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

Item {
	id: imageButton
	signal clicked
	property alias source: image.source
	property real naturalWidth: height*image.sourceSize.width/image.sourceSize.height

	height: windowHeight/16
	width: parent.width*15/16
	anchors.horizontalCenter: parent.horizontalCenter
	scale: mouseArea.pressed ? 0.9 : 1.0
	Behavior on scale { NumberAnimation { duration: 50 } }

	MouseArea {
		id: mouseArea
		anchors.fill: imageButton
		onClicked: imageButton.clicked()
	}
	Image {
		id: image
		height: imageButton.height
		// width set to preserve aspect ratio
		width: height*sourceSize.width/sourceSize.height
		anchors.centerIn: parent
		smooth: true
	}
}
