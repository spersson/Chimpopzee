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
import Qt.labs.particles 1.0

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
				plopper.play();
				_bubbleImage.opacity = 0;
				_highlightImage.opacity = 0;
				_splash1.sourceComponent = _splashComponent
				_splash1.item.source = "qrc:///particles/splash1"
				_splash2.sourceComponent = _splashComponent
				_splash2.item.source = "qrc:///particles/splash2"
				_splash1.item.burst(5);
				_splash2.item.burst(5);
				if(hasMonkey) {
					_stars1.sourceComponent = _starParticlesComponent
					_stars1.item.source = "qrc:///particles/redStar"
					_stars2.sourceComponent = _starParticlesComponent
					_stars2.item.source = "qrc:///particles/yellowStar"
					_stars3.sourceComponent = _starParticlesComponent
					_stars3.item.source = "qrc:///particles/blueStar"
					_bubble.z = 1;
					_monkeyFlight.start();
				} else {
					_pauseBeforeDeath.duration = _splash1.item.lifeSpan + _splash1.item.lifeSpanDeviation/2;
					_waitForSplash.start();
				}
			}
		}
	}

	SequentialAnimation {
		id: _waitForSplash
		PauseAnimation { id: _pauseBeforeDeath }
		ScriptAction { script: state = "KillMe" }
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
				_stars1.item.burst(10);
				_stars2.item.burst(10);
				_stars3.item.burst(10);
				_monkeyImage.opacity = 0;
				game.visibleRemainingTime = Math.min(game.visibleRemainingTime + gLevels[game.level].monkeyValue, timeBar.maxTime);
				game.timeInFlight -= gLevels[game.level].monkeyValue;
				_timeBarExtension.width =	timeBar.pixelsPerSecond*gLevels[game.level].monkeyValue;
				_timeBarExtension.height = timeBar.height;
				var lDest = mapFromItem(timeBar, timeBar.width - _timeBarExtension.width, 0);
				_timeBarExtension.x = lDest.x;
				_timeBarExtension.y = lDest.y;
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
		Image { source: "qrc:///bubbles/monkey" }
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
	}

	Image {
		id: _highlightImage
		source: "qrc:///bubbles/highlight"
		width: parent.width; height: parent.height
	}

	Rectangle {
		id: _timeBarExtension
		radius: height/3
		opacity: 0
	}

	Component {
		id: _splashComponent
		Particles {
			lifeSpan: 175; lifeSpanDeviation: 100
			velocity: 300; velocityDeviation: 00
			angle: 180; angleDeviation: 360
			emissionRate: 0
			fadeInDuration: 0; fadeOutDuration: 100
		}
	}

	Loader {
		id: _splash1
		anchors.fill: parent
	}

	Loader {
		id: _splash2
		anchors.fill: parent
	}

	Component {
		id: _starParticlesComponent
		Particles {
			lifeSpan: 650; lifeSpanDeviation: 700
			velocity: 200; velocityDeviation: 300
			angle:0; angleDeviation: 360
			emissionRate: 0
			fadeInDuration: 0; fadeOutDuration: 700
		}
	}

	Loader {
		id: _stars1
		anchors.fill: _monkeyImage
	}

	Loader {
		id: _stars2
		anchors.fill: _monkeyImage
	}

	Loader {
		id: _stars3
		anchors.fill: _monkeyImage
	}
}
