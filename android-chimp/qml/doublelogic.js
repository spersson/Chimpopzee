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

function rotateOnLeftBubble() {
	leftBubble.x = leftBubble.column*gameArea.bubbleSize;
	leftBubble.y = leftBubble.row*gameArea.bubbleSize;
	rightBubble.x = Qt.binding(function(){return leftBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*leftBubble.bubbleRotation/180)});
	rightBubble.y = Qt.binding(function(){return leftBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*leftBubble.bubbleRotation/180)});
}

function rotateOnRightBubble() {
	rightBubble.x = rightBubble.column*gameArea.bubbleSize;
	rightBubble.y = rightBubble.row*gameArea.bubbleSize;
	leftBubble.x = Qt.binding(function(){return rightBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*rightBubble.bubbleRotation/180)});
	leftBubble.y = Qt.binding(function(){return rightBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*rightBubble.bubbleRotation/180)});
}

function slideOnRightBubble() {
	leftBubble.x = leftBubble.column*gameArea.bubbleSize;
	leftBubble.y = Qt.binding(function(){return rightBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*rightBubble.bubbleRotation/180)});
	rightBubble.x = Qt.binding(function(){return leftBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*leftBubble.bubbleRotation/180)});
}

function slideOnLeftBubble() {
	rightBubble.x = rightBubble.column*gameArea.bubbleSize;
	rightBubble.y = Qt.binding(function(){return leftBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*leftBubble.bubbleRotation/180)});
	leftBubble.x = Qt.binding(function(){return rightBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*rightBubble.bubbleRotation/180)});
}

function rotateClockwise() {
	switch(angle) {
	case 0:
		rotateOnRightBubble();
		leftBubble.row = 0;
		leftBubble.column = 1;
		break;
	case 90:
		if(rightBubble.column === 0) {
			rotateOnRightBubble();
			leftBubble.row = 1;
			leftBubble.column = 1
		} else {
			slideOnRightBubble();
			leftBubble.row = 1;
			rightBubble.column = 0;
		}
		break;
	case 180:
		rotateOnLeftBubble();
		rightBubble.row = 0;
		rightBubble.column = 1;
		break;
	case 270:
		if(leftBubble.column === 0) {
			rotateOnLeftBubble();
			rightBubble.row = 1;
			rightBubble.column = 1
		} else {
			slideOnLeftBubble();
			rightBubble.row = 1;
			leftBubble.column = 0;
		}
		break;
	}
	angle = (angle + 90) % 360;
}

function rotateCounterClockwise() {
	switch(angle) {
	case 0:
		rotateOnLeftBubble();
		rightBubble.row = 0;
		rightBubble.column = 0;
		break;
	case 90:
		if(rightBubble.column === 1) {
			rotateOnRightBubble();
			leftBubble.row = 1;
			leftBubble.column = 0
		} else {
			slideOnRightBubble();
			leftBubble.row = 1;
			rightBubble.column = 1;
		}
		break;
	case 180:
		rotateOnRightBubble();
		leftBubble.row = 0;
		leftBubble.column = 0;
		break;
	case 270:
		if(leftBubble.column === 1) {
			rotateOnLeftBubble();
			rightBubble.row = 1;
			rightBubble.column = 0
		} else {
			slideOnLeftBubble();
			rightBubble.row = 1;
			leftBubble.column = 1;
		}
		break;
	}
	angle = (angle + 270) % 360;
}
