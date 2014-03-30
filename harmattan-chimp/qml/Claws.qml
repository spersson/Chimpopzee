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
	Image {
		id: leftClaw
		source: "qrc:///images/twigLeft"
		x: -width; y: gameArea.bubbleSize
		width: height*sourceSize.width/sourceSize.height; height: gameArea.bubbleSize
		smooth: true
	}

	Image {
		id: rightClaw
		source: "qrc:///images/twigRight"
		x:	gameArea.width; y: gameArea.bubbleSize
		width: height*sourceSize.width/sourceSize.height; height: gameArea.bubbleSize
		smooth: true
	}

	SequentialAnimation {
		id: inAnimation
		ScriptAction {
			script: game.bringInNewDouble()
		}
		ParallelAnimation {
			NumberAnimation {
				target: leftClaw; property: "x"
				from: -leftClaw.width
				to: gameArea.bubbleSize*gameArea.gameColumnCount/2 - leftClaw.width
				duration: 1000; easing.type: Easing.InOutQuad
			}
			NumberAnimation {
				target: rightClaw; property: "x"
				from: gameArea.width
				to: gameArea.bubbleSize*gameArea.gameColumnCount/2
				duration: 1000; easing.type: Easing.InOutQuad
			}

		}
		ScriptAction {
			script: game.prepareTheNewDouble()
		}
	}

	ParallelAnimation {
		id: outAnimation
		NumberAnimation {
			target: leftClaw; property: "x"; to: -leftClaw.width
			duration: 1000; easing.type: Easing.InOutQuad
		}
		NumberAnimation {
			target: rightClaw; property: "x"; to: gameArea.width
			duration: 1000; easing.type: Easing.InOutQuad
		}
	}

	function bringInClaws() {
		inAnimation.start();
	}

	function stopBringingInClaws() {
		inAnimation.stop();
	}

	function bringOutClaws() {
		outAnimation.start();
	}
}