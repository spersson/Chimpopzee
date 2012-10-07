import QtQuick 1.1

import "doublelogic.js" as DoubleLogic

Item {
	property int angle: 0
	property int cRotateDuration: 120
	property int column

	property alias leftRow: _leftBubble.row
	property alias leftColumn: _leftBubble.column
	property alias rightRow: _rightBubble.row
	property alias rightColumn: _rightBubble.column

	property alias leftBubble: _leftBubble
	property alias rightBubble: _rightBubble
	property alias bringInLeft: _bringInLeft
	property alias bringInRight: _bringInRight

	state: "In Claw"

	Behavior on x {
		enabled: state === "Falling"
		SmoothedAnimation { duration: cRotateDuration }
	}
	function rotateClockwise() {DoubleLogic.rotateClockwise();}
	function rotateCounterClockwise() {DoubleLogic.rotateCounterClockwise();}

	Bubble {
		id: _leftBubble;
		bubbleRotation: angle
		row: 1; y: gameArea.bubbleSize
		column: 0; x: 0
		Behavior on bubbleRotation {
			RotationAnimation {
				duration: cRotateDuration; direction: RotationAnimation.Shortest; easing.type: Easing.OutQuad
			}
		}
	}
	Bubble {
		id: _rightBubble;
		bubbleRotation: (angle + 180) % 360
		row: 1; y: gameArea.bubbleSize
		column: 1; x: gameArea.bubbleSize
		Behavior on bubbleRotation {
			RotationAnimation {
				duration: cRotateDuration; direction: RotationAnimation.Shortest; easing.type: Easing.OutQuad
			}
		}
	}
	NumberAnimation {
		id: _bringInLeft
		target: _leftBubble; property: "x"; to: 0
		duration: 1000; easing.type: Easing.InOutQuad
	}
	NumberAnimation {
		id: _bringInRight
		target: _rightBubble; property: "x"; to: gameArea.bubbleSize
		duration: 1000; easing.type: Easing.InOutQuad
	}
}
