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
	id: _bubble
	property bool hasMonkey: false
	property bool single: true
	property string color
	property int column
	property int row

	property alias bubbleRotation:_bubbleImage.rotation
	property alias popDelay: _waitBeforePop.duration
	property alias popSequence: _popSequence
	property alias monkeyFlightX: _monkeyFlightX
	property alias monkeyFlightY: _monkeyFlightY
	property alias timeBarExtension: _timeBarExtension

	x: column*gameArea.bubbleSize
	y: row*gameArea.bubbleSize
	width: gameArea.bubbleSize
	height: gameArea.bubbleSize

	function startHidden() {
		_appearanceDelay.duration = Math.floor(Math.random()*1000);
		_appear.start();
	}

	SequentialAnimation {
		id: _appear
		ScriptAction { script: visible = false }
		PauseAnimation { id: _appearanceDelay }
		ScriptAction { script: visible = true }
		NumberAnimation {
			target: _bubble; property: "scale"
			easing.period: 0.37; easing.amplitude: 1.25; easing.type: Easing.OutElastic
			duration: 800
			from: 0.1; to: 1.0
		}
	}

	SequentialAnimation {
		id: _popSequence
		PauseAnimation { id: _waitBeforePop }
		ScriptAction {
			script: {
				sounds.item.playPlopp();
				_bubbleImage.opacity = 0;
				_highlightImage.opacity = 0;
				particles.item.splashBubble(particles.mapFromItem(_bubble, _bubble.width/2, _bubble.height/2));
				if(hasMonkey) {
					_bubble.z = 1;
					_monkeyFlight.start();
				} else {
					state = "KillMe";
				}
			}
		}
	}

	SequentialAnimation {
		id: _monkeyFlight
		ParallelAnimation {
			NumberAnimation {
				id: _monkeyFlightX
				target: _monkeyImage; property: "x"
				easing.type: Easing.InQuad
			}
			NumberAnimation {
				id: _monkeyFlightY
				target: _monkeyImage; property: "y"
				easing.type: Easing.InQuad
			}
		}
		ScriptAction {
			script: {
				particles.item.burstStars(particles.mapFromItem(_bubble, _monkeyImage.x + _monkeyImage.width/2, _monkeyImage.y + _monkeyImage.height));
				_monkeyImage.opacity = 0;
				game.visibleRemainingTime = Math.min(game.visibleRemainingTime + gLevels[game.level].monkeyValue, game.maxVisibleTime);
				game.timeInFlight -= gLevels[game.level].monkeyValue;
				var lGeometry = bottomBar.item.getTimebarExtensionPosition(_bubble);
				_timeBarExtension.x = lGeometry.x;
				_timeBarExtension.y = lGeometry.y;
				_timeBarExtension.width = lGeometry.width;
				_timeBarExtension.height = lGeometry.height;
				_timeBarExtension.opacity = 1;
			}
		}
		ColorAnimation { target: _timeBarExtension; property: "color"; from: "#938373"; to: "#534333"; duration: 1000 }
		ScriptAction {
			script: {
				state = "KillMe"
			}
		}
	}

	Component {
		id: _monkeyComponent
		Image {
			source: "qrc:///bubbles/monkey"
			sourceSize.height: height
		}
	}

	Loader {
		id: _monkeyImage
		width: parent.width; height: parent.height
		sourceComponent: hasMonkey ? _monkeyComponent: undefined
	}

	Image {
		id: _bubbleImage
		source: "qrc:///bubbles/" + color + (single ? "s" : "d")
		width: parent.width; height: parent.height
		sourceSize.height: parent.height
	}

	Image {
		id: _highlightImage
		source: "qrc:///bubbles/highlight"
		width: parent.width; height: parent.height
		sourceSize.height: parent.height
	}

	Rectangle {
		id: _timeBarExtension
		radius: height/3
		opacity: 0
	}
}
