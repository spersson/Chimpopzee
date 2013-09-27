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
import com.nokia.meego 1.0
import QtMultimediaKit 1.1

import "gamelogic.js" as GameLogic
import "tutorial.js" as Tutorial

Window {
	id: game
	property int level
	property int remainingMonkeys
	property int remainingTime
	property int visibleRemainingTime
	property int timeInFlight: 0
	property bool active: Qt.application.active
	property int windowHeight: screen.rotation === 0 || screen.rotation === 180 ? screen.displayHeight : screen.displayWidth
	property int windowWidth: screen.rotation === 0 || screen.rotation === 180 ? screen.displayWidth : screen.displayHeight
	onActiveChanged: {
		if(active) {
			screen.allowSwipe = true;
		} else if(state === "Running") {
			state = "Pause Menu";
		}
	}

	Component.onCompleted: {
		screen.allowedOrientations = Screen.Portrait | Screen.PortraitInverted;
		levelView.positionViewAtIndex(gLevelModel.unlockedCount(), GridView.End);
	}

	states: [
		State {
			name: "Running"
			PropertyChanges { target: screen; allowSwipe: false }
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
			AnchorChanges { target: pauseMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.left: undefined }
		},
		State {
			name: "Main Level Menu"
			AnchorChanges { target: levelMenu; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		},
		State {
			name: "Pause Level Menu"
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
			name: "Tutorial"
			AnchorChanges { target: tutorial; anchors.horizontalCenter: parent.horizontalCenter; anchors.right: undefined }
		}
	]
	state: "Main Menu"
	transitions: Transition { AnchorAnimation { duration: 500; easing.type: Easing.OutQuad } }

	SoundEffect { id: plopper; source: "qrc:///sounds/plopp" }

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
		anchors.fill: parent
	}

	Text {
		visible: game.state !== "Main Menu" && game.state !== "Main Level Menu" && game.state !== "Tutorial" && game.state !== "About Menu"
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

	Rectangle {
		id: bottomBar
		height: windowHeight/16; width: parent.width
		radius: height/6
		anchors {
			margins: border.width/2
			top: parent.bottom
		}

		ImageButton {
			id: pauseButton
			source: "qrc:///buttons/pause";
			height: bottomBar.height
			anchors {
				left: parent.left
				verticalCenter: parent.verticalCenter
			}
			onClicked: if(game.state === "Running") game.state = "Pause Menu";
		}

		Rectangle {
			id: timeBarBackground
			color: "#f9eec3"
			border.width: 3
			border.color: "black"
			height: bottomBar.height - 2*bottomBar.radius
			radius: height/3
			anchors {
				left: pauseButton.right
				right: bottomBar.right; rightMargin: 5
				verticalCenter: parent.verticalCenter
			}

			SequentialAnimation {
				ColorAnimation {target: timeBarBackground; property: "color"; duration: 250; to: "red"}
				ColorAnimation {target: timeBarBackground; property: "color"; duration: 150; to: "#f9eec3"}
				ColorAnimation {target: timeBarBackground; property: "color"; duration: 250; to: "red"}
				ColorAnimation {target: timeBarBackground; property: "color"; duration: 150; to: "#f9eec3"}
				PauseAnimation {duration: 400}
				loops: Animation.Infinite
				alwaysRunToEnd: true
				running: game.state === "Running" && game.remainingTime < 15
			}

			Rectangle {
				id: timeBar
				property real maxTime: 120
				property real pixelsPerSecond: (timeBarBackground.width - 8)/maxTime
				color: "#534333"
				height: timeBarBackground.height - 8
				radius: height/3
				anchors {
					left: parent.left; leftMargin: 4
					verticalCenter: parent.verticalCenter
				}
				width: game.visibleRemainingTime*pixelsPerSecond
			}
		}
	}

	Item {
		id: gameArea
		property int gameColumnCount: 8
		property int bubbleSize: Math.floor(parent.width/gameColumnCount)
		property int thresholdSize: 0.06*screen.dpi
		property int gameRowCount: Math.ceil((windowHeight - bottomBar.height - bottomBar.border.width)/bubbleSize)
		property real fallSpeed: gLevels[game.level].fallSpeed*bubbleSize/1000
		property real sequenceFallSpeed: 4*bubbleSize/1000
		property bool newDoubleReady: false

		property alias bringInClaws: _bringInClaws
		property alias	bringOutClaws: _bringOutClaws

		width: gameColumnCount * bubbleSize
		height: gameRowCount * bubbleSize
		y: windowHeight - bottomBar.height - bottomBar.border.width - height
		anchors.horizontalCenter: parent.horizontalCenter

		MouseArea {
			anchors.fill: parent
			enabled: game.state === "Running"
			onPressed: GameLogic.onMouseDown(mouse)
			onMousePositionChanged: GameLogic.onMouseMove(mouse)
			onReleased: GameLogic.onMouseRelease(mouse)
			onClicked: GameLogic.onMouseClick(mouse)
		}

		Image {
			id: leftClaw
			source: "qrc:///images/twigLeft"
			x: -gameArea.x - width; y: gameArea.bubbleSize
			width: height*sourceSize.width/sourceSize.height; height: gameArea.bubbleSize
			smooth: true
		}

		Image {
			id: rightClaw
			source: "qrc:///images/twigRight"
			x:	gameArea.x + gameArea.width; y: gameArea.bubbleSize
			width: height*sourceSize.width/sourceSize.height; height: gameArea.bubbleSize
			smooth: true
		}

		SequentialAnimation {
			id: _bringInClaws
			ScriptAction {
				script: {
					GameLogic.createNewFallingDouble();
					GameLogic.gNextFallingDouble.bringInLeft.start();
					GameLogic.gNextFallingDouble.bringInRight.start();
				}
			}
			ParallelAnimation {
				NumberAnimation {
					target: leftClaw; property: "x"
					from: -gameArea.x - leftClaw.width
					to: gameArea.bubbleSize*gameArea.gameColumnCount/2 - leftClaw.width
					duration: 1000; easing.type: Easing.InOutQuad
				}
				NumberAnimation {
					target: rightClaw; property: "x"
					from: gameArea.x + gameArea.width
					to: gameArea.bubbleSize*gameArea.gameColumnCount/2
					duration: 1000; easing.type: Easing.InOutQuad
				}

			}
			ScriptAction {
				script: {
					GameLogic.gNextFallingDouble.leftBubble.single = false;
					GameLogic.gNextFallingDouble.rightBubble.single = false;
					gameArea.newDoubleReady = true;
					if(gameArea.state === "Waiting for New Double") {
						GameLogic.startDoubleFalling();
					}
				}
			}
		}

		ParallelAnimation {
			id: _bringOutClaws
			NumberAnimation {
				target: leftClaw; property: "x"; to: -gameArea.x - leftClaw.width
				duration: 1000; easing.type: Easing.InOutQuad
			}
			NumberAnimation {
				target: rightClaw; property: "x"; to: gameArea.x + gameArea.width
				duration: 1000; easing.type: Easing.InOutQuad
			}
		}
	}

	MenuCard {
		id: mainMenu
		anchors {left: parent.right; verticalCenter: parent.verticalCenter}
		Image {
			id: monkeyLogo
			source: "qrc:///bubbles/monkey"
			height: windowHeight/3; width: height
			smooth: true
			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
			}
		}
		Column {
			anchors {
				top: monkeyLogo.bottom
				left: parent.left; right: parent.right
			}
			spacing: windowHeight/24
			ImageButton {
				source: "qrc:///buttons/startNew"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: { if(game.state === "Main Menu") game.state = "Main Level Menu"; else game.state = "Pause Level Menu" }
			}
			ImageButton {
				source: "qrc:///buttons/tutorial"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: { tutorial.pageNumber = 1; game.state = "Tutorial" }
			}
			ImageButton {
				source: "qrc:///buttons/about"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: game.state = "About Menu"
			}
			ImageButton {
				source: "qrc:///buttons/quit"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: Qt.quit()
			}
		}
	}

	MenuCard {
		id: pauseMenu
		anchors { left: parent.right; verticalCenter: parent.verticalCenter }
		Column {
			anchors {
				margins: windowHeight/32
				verticalCenter: parent.verticalCenter
				left: parent.left; right: parent.right
			}
			spacing: windowHeight/16

			ImageButton {
				source: "qrc:///buttons/resume"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: game.state = "Running"
			}

			ImageButton {
				source: "qrc:///buttons/restart"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: GameLogic.startNewGame(game.level)
			}

			ImageButton {
				source: "qrc:///buttons/startNew"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: { if(game.state === "Main Menu") game.state = "Main Level Menu"; else game.state = "Pause Level Menu" }
			}

			ImageButton {
				source: "qrc:///buttons/quit"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: Qt.quit()
			}
		}
	}

	MenuCard {
		id: levelMenu
		anchors { right: parent.left; verticalCenter: parent.verticalCenter }

		Rectangle {
			id: levelContainer
			anchors {
				fill: parent
				topMargin: windowHeight/32; bottomMargin: windowHeight/16
				leftMargin: windowHeight/32; rightMargin: windowHeight/32
			}
			radius: height/24
			border.width: 2
			border.color: "#534333"
			color: "#f9eec3"

			GridView {
				id: levelView
				anchors {
					fill: parent
					topMargin: levelContainer.border.width/2; bottomMargin: levelContainer.border.width/2
					leftMargin: levelContainer.radius; rightMargin: levelContainer.radius
				}
				model: gLevelModel
				cellWidth: width/4.1 // ensure 4 buttons on a row
				cellHeight: cellWidth*1.3 // a bit extra margin between rows
				clip: true
				function startNew(pIndex) { GameLogic.startNewGame(pIndex) }
				delegate: LevelButton{}
			}
		}

		ImageButton {
			id: levelBackButton
			source: "qrc:///buttons/mainMenu"
			height: windowHeight*3/64
			width: parent.width*15/16
			anchors {
				horizontalCenter: parent.horizontalCenter
				top: levelContainer.bottom
				margins: windowHeight/128
			}
			onClicked: { if(game.state === "Main Level Menu") game.state = "Main Menu"; else game.state = "Pause Menu" }
		}
	}

	MenuCard {
		id: gameOverMenu
		anchors {right: parent.left; verticalCenter: parent.verticalCenter}
		Column {
			anchors {
				margins: windowHeight/32
				verticalCenter: parent.verticalCenter
				left: parent.left; right: parent.right
			}
			spacing: windowHeight/16

			Text{
				id: gameOverText1
				width: parent.width
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: windowHeight/20
			}
			Text{
				id: gameOverText2
				width: parent.width
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: windowHeight/24
			}
			ImageButton {
				source: "qrc:///buttons/restart"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: GameLogic.startNewGame(game.level)
			}
			ImageButton {
				source: "qrc:///buttons/mainMenu"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: {GameLogic.clearAllBubbles(); game.state = "Main Menu"}
			}
		}
	}

	MenuCard {
		id: nextLevelMenu
		anchors {right: parent.left; verticalCenter: parent.verticalCenter}
		Column {
			anchors {
				margins: windowHeight/32
				verticalCenter: parent.verticalCenter
				left: parent.left; right: parent.right
			}
			spacing: windowHeight/16

			Text{
				id: nextLevelText1
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: windowHeight/20
			}
			Text{
				id: nextLevelText2
				width: parent.width
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: windowHeight/24
			}
			ImageButton {
				source: "qrc:///buttons/nextLevel"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: GameLogic.startNewGame(game.level + 1)
			}
			ImageButton {
				source: "qrc:///buttons/mainMenu"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: {GameLogic.clearAllBubbles(); game.state = "Main Menu"}
			}
		}
	}

	MenuCard {
		id: aboutMenu
		anchors {right: parent.left; verticalCenter: parent.verticalCenter}
		Column {
			anchors {
				margins: windowHeight/32
				verticalCenter: parent.verticalCenter
				left: parent.left; right: parent.right
			}
			spacing: windowHeight/16

			Text{
				text: "Chimpopzee v1.0"
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: windowHeight/20
			}

			Text{
				text:"Copyright Simon Persson 2012. Licensed under the GNU General Public License (GPL) version 2 or later.\n" +
				     "Chimp icon by Jakub Steiner.\n" +
				     "Source code available at https://github.com/spersson/Chimpopzee"
				width: parent.width
				wrapMode: Text.Wrap
				font.pixelSize: windowHeight/48
			}

			ImageButton {
				source: "qrc:///buttons/mainMenu"
				height: windowHeight/16
				width: parent.width*15/16
				anchors.horizontalCenter: parent.horizontalCenter
				onClicked: { game.state = "Main Menu" }
			}
		}
	}

	MenuCard {
		id: tutorial
		property int pageNumber: 1
		anchors {right: parent.left; verticalCenter: parent.verticalCenter}

		Column {
			anchors {
				margins: windowHeight/32
				top: parent.top
				left: parent.left; right: parent.right
			}
			spacing: windowHeight/48

			Image {
				source: Tutorial.images[tutorial.pageNumber - 1]
				anchors.horizontalCenter: parent.horizontalCenter
				height: windowHeight/2.5
				width: height*sourceSize.width/sourceSize.height
			}

			Text{
				text: Tutorial.texts[tutorial.pageNumber - 1]
				width: parent.width
				wrapMode: Text.Wrap
				font.pixelSize: windowHeight/48
			}
		}

		Column {
			anchors {
				margins: windowHeight/48
				bottom: parent.bottom
				left: parent.left; right: parent.right
			}
			spacing: windowHeight/48

			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				ImageButton {
					source: "qrc:///buttons/previous"
					opacity: tutorial.pageNumber != 1 ? 1 : 0.2
					height: windowHeight/16
					onClicked: if(tutorial.pageNumber > 1) tutorial.pageNumber--;
				}

				Text {
					text: tutorial.pageNumber + "/" + Tutorial.texts.length
					anchors.verticalCenter: parent.verticalCenter
					verticalAlignment: Text.AlignVCenter
					font.pixelSize: windowHeight/32
				}

				ImageButton {
					source: "qrc:///buttons/next"
					opacity: tutorial.pageNumber != Tutorial.texts.length ? 1 : 0.2
					height: windowHeight/16
					onClicked: if(tutorial.pageNumber < Tutorial.texts.length) tutorial.pageNumber++;
				}
			}

			ImageButton {
				source: "qrc:///buttons/mainMenu"
				anchors.horizontalCenter: parent.horizontalCenter
				height: windowHeight/16
				width: parent.width*15/16
				onClicked: { game.state = "Main Menu" }
			}
		}
	}
}
