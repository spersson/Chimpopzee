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

import "doublelogic.js" as DoubleLogic

Item {
	property int angle: 0
	property int cRotateDuration: 120
	property int column

	property Bubble leftBubble: Bubble {
		bubbleRotation: angle
		row: 1; y: gameArea.bubbleSize
		column: 0; x: 0
		Behavior on bubbleRotation {
			RotationAnimation {
				duration: cRotateDuration; direction: RotationAnimation.Shortest; easing.type: Easing.OutQuad
			}
		}
	}
	property Bubble rightBubble: Bubble {
		bubbleRotation: (angle + 180) % 360
		row: 1; y: gameArea.bubbleSize
		column: 1; x: gameArea.bubbleSize
		Behavior on bubbleRotation {
			RotationAnimation {
				duration: cRotateDuration; direction: RotationAnimation.Shortest; easing.type: Easing.OutQuad
			}
		}
	}
	children: [leftBubble, rightBubble]
	property NumberAnimation bringInLeft: NumberAnimation {
		target: leftBubble; property: "x"; to: 0
		duration: 1000; easing.type: Easing.InOutQuad
	}
	property NumberAnimation bringInRight: NumberAnimation {
		target: rightBubble; property: "x"; to: gameArea.bubbleSize
		duration: 1000; easing.type: Easing.InOutQuad
	}

	state: "In Claw"

	Behavior on x {
		enabled: state === "Falling"
		SmoothedAnimation { duration: cRotateDuration }
	}
	function rotateClockwise() {DoubleLogic.rotateClockwise();}
	function rotateCounterClockwise() {DoubleLogic.rotateCounterClockwise();}
}
