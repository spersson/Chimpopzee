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

Rectangle {
	height: game.bottomBarHeight
	radius: height/6
	anchors.margins: border.width/2

	ImageButton {
		id: pauseButton
		source: "qrc:///buttons/pause";
		height: parent.height
		width: naturalWidth
		anchors {
			left: parent.left
			horizontalCenter: undefined
			verticalCenter: parent.verticalCenter
		}
		onClicked: if(game.state === "Running") { game.state = "Pause Menu"; }
	}

	Rectangle {
		id: timeBarBackground
		property real pixelsPerSecond: (width - 8)/game.maxVisibleTime
		color: "#f9eec3"
		border.width: 3
		border.color: "black"
		height: parent.height - 2*parent.radius
		radius: height/3
		anchors {
			left: pauseButton.right
			right: parent.right; rightMargin: 5
			verticalCenter: parent.verticalCenter
		}

		Rectangle {
			id: timeBar
			color: "#534333"
			height: parent.height - 8
			radius: height/3
			anchors {
				left: parent.left; leftMargin: 4
				verticalCenter: parent.verticalCenter
			}
			width: game.visibleRemainingTime*timeBarBackground.pixelsPerSecond
		}
	}

	SequentialAnimation {
		ColorAnimation {target: timeBarBackground; property: "color"; duration: 100; to: "red"}
		ColorAnimation {target: timeBarBackground; property: "color"; duration: 200; to: "#f9eec3"}
		ColorAnimation {target: timeBarBackground; property: "color"; duration: 100; to: "red"}
		ColorAnimation {target: timeBarBackground; property: "color"; duration: 200; to: "#f9eec3"}
		PauseAnimation {duration: 400}
		loops: Animation.Infinite
		alwaysRunToEnd: true
		running: game.state === "Running" && game.remainingTime < 15
	}

	function getMonkeyFlightDestination(pCoordinateSystem) {
		var lBarXDest = Math.min(timeBar.width - gameArea.bubbleSize/2 + game.timeInFlight*timeBarBackground.pixelsPerSecond,
		                         game.maxVisibleTime*timeBarBackground.pixelsPerSecond);
		return pCoordinateSystem.mapFromItem(timeBar, lBarXDest, timeBar.height - gameArea.bubbleSize);
	}

	function getTimebarExtensionPosition(pCoordinateSystem) {
		var result = pCoordinateSystem.mapFromItem(timeBar, timeBar.width, 0);
		result.width = timeBarBackground.pixelsPerSecond*gLevels[game.level].monkeyValue;
		result.height = timeBar.height;
		result.x -= result.width;
		return result;
	}
}
