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
import QtQuick.Window 2.0

import "gamelogic.js" as GameLogic

Item {
	id: game
	property int level: 0
	property int remainingMonkeys: 0
	property int remainingTime: 0
	property int visibleRemainingTime: 0
	property int timeInFlight: 0
	property int windowHeight: height
	property int windowWidth: width
	property int bottomBarHeight: windowHeight/16
	property real maxVisibleTime: 120
	property int thresholdSize: 0.06*25.4*Screen.logicalPixelDensity;
	property string gameOverCaption
	property string gameOverMessage
	property bool active: Qt.application.active
	onActiveChanged: {
		if(active) {

		} else if(state === "Running") {
			state = "Pause Menu";
		}
	}

	states: [
		State {
			name: "Running"
			StateChangeScript {
				script: GameLogic.updateTimestamp();
			}
			AnchorChanges { target: bottomBar; anchors.top: gameArea.bottom }
		},
		State {
			name: "Main Menu"
			AnchorChanges { target: mainMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.left: undefined }
		},
		State {
			name: "Pause Menu"
			AnchorChanges { target: pauseMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "Level Menu"
			AnchorChanges { target: levelMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "Game Over"
			AnchorChanges { target: gameOverMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "Next Level"
			AnchorChanges { target: nextLevelMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "About Menu"
			AnchorChanges { target: aboutMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "Tutorial Menu"
			AnchorChanges { target: tutorialMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "Highscore Menu"
			AnchorChanges { target: highScoreMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "Submission Menu"
			AnchorChanges {
				target: submissionMenu;
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.right: undefined
				anchors.left: undefined
			}
			AnchorChanges { target: highScoreMenu; anchors.left: parent.right; anchors.right: undefined }
		}
	]
	state: "Main Menu"
	transitions: Transition { AnchorAnimation { duration: 500; easing.type: Easing.OutQuad } }

	focus: true
	Keys.onPressed: {
		if(event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
			event.accepted = true;
			switch(state) {
			case "Tutorial Menu":
			case "About Menu":
			case "Highscore Menu":
			case "Level Menu":
				state = "Main Menu";
				break;
			case "Running":
				state = "Pause Menu";
				break;
			case "Submission Menu":
				if(gHighScoresModel.haveScores) {
					state = "Highscore Menu";
				} else {
					state = "Main Menu";
				}
				break;
			case "Main Menu":
				Qt.quit();
				break;
			}
		}
	}


	Timer {
		interval: 10; repeat: true;
		running: game.state === "Running" && game.active
		onTriggered: GameLogic.animateFallingBubbles()
	}

	Timer {
		interval: 1000; repeat: true;
		running: game.state === "Running" && game.active
		onTriggered: GameLogic.decreaseRemainingTime()
	}

	Image {
		source: "qrc:///images/background"
		fillMode: Image.Tile
		z: -10
		anchors {
			top: parent.top
			bottom: parent.bottom
			left: gameArea.left
			right: gameArea.right
		}
	}

	Text {
		visible: game.state === "Running" || game.state === "Pause Menu" || game.state === "Next Level" || game.state === "Game Over"
		color: "#f9eec3"
		opacity: 0.2
		text: "Level " + (game.level + 1)
		font.pixelSize: gameArea.width/4
		anchors {
			left: gameArea.right; leftMargin: height/7
			bottom: gameArea.bottom
		}
		transformOrigin: Item.BottomLeft
		rotation: -90
	}

	MouseArea {
		id: tapAndDragArea
		anchors.fill: parent
		z: -10
		enabled: game.state === "Running"
		onPressed: GameLogic.onMouseDown(mouse)
		onPositionChanged: GameLogic.onMouseMove(mouse)
		onReleased: GameLogic.onMouseRelease(mouse)
	}

	Item {
		id: gameArea
		property int gameRowCount: 11
		property int gameColumnCount: 8
		property int bubbleSize: Math.min(Math.floor(windowWidth/gameColumnCount),
		                                  Math.floor(windowHeight/gameRowCount))

		property real fallSpeed: gLevels[game.level].fallSpeed*bubbleSize/1000
		property real sequenceFallSpeed: 4*bubbleSize/1000
		property bool newDoubleReady: false

		width: gameColumnCount * bubbleSize
		height: gameRowCount * bubbleSize
		y: windowHeight - bottomBarHeight - height
		anchors.horizontalCenter: parent.horizontalCenter

		Loader {
			id: claws
		}
	}

	Rectangle {
		color: "black"
		height: windowHeight
		width: windowWidth/2
		anchors {
			left: gameArea.right
			top: parent.top
		}
	}

	Rectangle {
		color: "black"
		height: windowHeight
		width: windowWidth/2
		anchors {
			right: gameArea.left
			top: parent.top
		}
	}

	Loader {
		id: bottomBar
		z: -1 // ensure that it gets below gameArea and therefore all the flying monkeys.
		anchors {
			top: parent.bottom
			left: gameArea.left
			right: gameArea.right
		}
	}

	Loader {
		id: particles
	}

	Loader {
		id: sounds
	}

	MenuCardLoader {
		id: levelMenu
	}

	MenuCardLoader {
		id: tutorialMenu
	}

	MenuCardLoader {
		id: aboutMenu
	}

	MenuCardLoader {
		id: highScoreMenu
		anchors.right: gHighScoresModel.haveScores ? parent.left: undefined
		anchors.left: gHighScoresModel.haveScores ? undefined: parent.right
	}

	MenuCardLoader {
		id: submissionMenu
	}

	MenuCardLoader {
		id: pauseMenu
	}

	MenuCardLoader {
		id: nextLevelMenu
	}

	MenuCardLoader {
		id: gameOverMenu
	}

	MainMenu {
		id: mainMenu
	}

	function restartLevel() {
		GameLogic.startNewGame(game.level);
	}

	function startNextLevel() {
		GameLogic.startNewGame(game.level + 1);
	}

	function startLevel(pLevel) {
		particles.source = Qt.resolvedUrl("Particles.qml");
		sounds.source = Qt.resolvedUrl("Sounds.qml");
		pauseMenu.source = Qt.resolvedUrl("PauseMenu.qml");
		nextLevelMenu.source = Qt.resolvedUrl("NextLevelMenu.qml");
		gameOverMenu.source = Qt.resolvedUrl("GameOverMenu.qml");
		bottomBar.source = Qt.resolvedUrl("BottomBar.qml");
		claws.source = Qt.resolvedUrl("Claws.qml");
		GameLogic.startNewGame(pLevel);
	}

	function returnToMainMenu() {
		GameLogic.clearAllBubbles();
		claws.item.bringOutClaws();
		game.state = "Main Menu"
	}

	function bringInNewDouble() {
		GameLogic.createNewFallingDouble();
		GameLogic.gNextFallingDouble.bringInLeft.start();
		GameLogic.gNextFallingDouble.bringInRight.start();
	}

	function prepareTheNewDouble() {
		GameLogic.gNextFallingDouble.leftBubble.single = false;
		GameLogic.gNextFallingDouble.rightBubble.single = false;
		gameArea.newDoubleReady = true;
		if(gameArea.state === "Waiting for New Double") {
			GameLogic.startDoubleFalling();
		}
	}
}
