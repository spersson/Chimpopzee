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

var gColors = ["red", "green", "blue", "yellow", "purple"];

function Grid(width, height) {
	this.width = width
	this.height = height
	this.cells = new Array(width * height)
}

Grid.prototype.valueAt = function(r, c) {
	return this.cells[r * this.width + c]
}

Grid.prototype.setValueAt = function(r, c, value) {
	this.cells[r * this.width + c] = value
}

function killKillKill(pVictim) {
	if(pVictim) {
		pVictim.opacity = 0;
		pVictim.destroy();
	}
}

var gGameGrid;
var gFallingDouble;
var gNextFallingDouble;
var gFallingBubbles = [];
var gPoppingBubbles = [];

var gBubbleDragStartX;
var gDragStartX;
var gDragStartY;
var gDragLastX;
var gDragLastY;
var gSpeedAddition = 0;
var gDragSpeedX = 0;
var gFilteredFingerX;
var gCouldBeAClick;
var gFingerDownTime;

var gLastFallUpdate;
var gLastMouseMoveTime;

var gBlockCounter;
var gMouseDownBlockNr;


function onMouseDown(mouseEvent) {
	gDragStartX = mouseEvent.x;
	gDragStartY = mouseEvent.y;
	gDragLastX = mouseEvent.x;
	gDragLastY = mouseEvent.y;
	gFilteredFingerX = mouseEvent.x;
	gDragSpeedX = 0;
	gCouldBeAClick = true;
	gLastMouseMoveTime = Date.now();
	gMouseDownBlockNr = gBlockCounter;
	if(gameArea.state === "Double Falling") {
		gBubbleDragStartX = gFallingDouble.x;
	} else {
		gBubbleDragStartX = (gameArea.gameColumnCount/2 - 1)*gameArea.bubbleSize;
	}
	gFingerDownTime = Date.now();
}

function onMouseMove(mouseEvent) {
	if(gameArea.state !== "Double Falling") {
		gLastMouseMoveTime = Date.now();
		gDragLastX = mouseEvent.x;
		gDragLastY = mouseEvent.y;
		return;
	}

	if(gMouseDownBlockNr !== gBlockCounter) {
		return;
	}

	if(Math.abs(mouseEvent.x - gDragStartX) > game.thresholdSize) {
		gCouldBeAClick = false;
		gFallingDouble.state = "Dragging";
	}

	if(Math.abs(mouseEvent.y - gDragStartY) > game.thresholdSize) {
		gCouldBeAClick = false;
	}

	var lNewTime = Date.now();
	var lTimeDiff = lNewTime - gLastMouseMoveTime;

	if(lTimeDiff > 10) {
		var lYSpeed = (mouseEvent.y - gDragLastY)/lTimeDiff;
		gLastMouseMoveTime = lNewTime;
		gDragLastY = mouseEvent.y;

		if(lYSpeed > gameArea.fallSpeed) {
			gSpeedAddition = Math.min(0.6*(lYSpeed - gameArea.fallSpeed) + 0.4*gSpeedAddition, gameArea.bubbleSize*30/1000);
		}

		if(gFallingDouble.state === "Dragging") {
			var lXSpeed = (mouseEvent.x - gDragLastX)/lTimeDiff;
			gDragSpeedX = 0.6*lXSpeed + 0.4*gDragSpeedX;
			gDragLastX = mouseEvent.x;
		}
	}
}

function onMouseRelease(mouseEvent) {
	if(gMouseDownBlockNr !== gBlockCounter || gameArea.state !== "Double Falling") {
		return;
	}

	if(gFallingDouble && gFallingDouble.state === "Dragging") {
		gFallingDouble.state = "Falling";
		gFallingDouble.x = gFallingDouble.column * gameArea.bubbleSize;
	}
}

function onMouseClick(mouseEvent) {
	function isBothRowsOccupied(pColumn, pY) {
		return gGameGrid.valueAt(Math.floor(pY), pColumn) || gGameGrid.valueAt(Math.ceil(pY), pColumn);
	}

	function isMostlyOccupied(pColumn, pY) {
		return gGameGrid.valueAt(Math.ceil(pY), pColumn) || (gGameGrid.valueAt(Math.floor(pY), pColumn) && pY - Math.floor(pY) < 0.75);
	}

	if(!gCouldBeAClick || gMouseDownBlockNr !== gBlockCounter || gameArea.state !== "Double Falling" || Date.now() - gFingerDownTime > 350) {
		return;
	}
	var lWantsCCW = false;
	if(mouseEvent.x < tapAndDragArea.width/2) {
		lWantsCCW = true;
	}

	var lUnitY = gFallingDouble.y/gameArea.bubbleSize;

	if(gFallingDouble.leftRow === 0 || gFallingDouble.rightRow ===0) {
		if(gFallingDouble.leftColumn === 0) { // double in left column
			if(lWantsCCW) {
				if(gFallingDouble.column < gGameGrid.width - 1 &&
				   !isMostlyOccupied(gFallingDouble.column + 1, lUnitY + 1)) {
					gFallingDouble.rotateCounterClockwise();
				} else if(gFallingDouble.column > 0 &&
				          !isBothRowsOccupied(gFallingDouble.column - 1, lUnitY + 1) &&
				          !isMostlyOccupied(gFallingDouble.column - 1, lUnitY)) {
					gFallingDouble.x -= gameArea.bubbleSize;
					gFallingDouble.column -= 1;
					gFallingDouble.rotateCounterClockwise();
				}
			} else {
				if(gFallingDouble.column < gGameGrid.width - 1 &&
				   !isBothRowsOccupied(gFallingDouble.column + 1, lUnitY + 1) &&
				   !isMostlyOccupied(gFallingDouble.column + 1, lUnitY)) {
					gFallingDouble.rotateClockwise();
				} else if(gFallingDouble.column > 0 &&
				          !isMostlyOccupied(gFallingDouble.column - 1, lUnitY + 1)) {
					gFallingDouble.x -= gameArea.bubbleSize;
					gFallingDouble.column -= 1;
					gFallingDouble.rotateClockwise();
				}
			}
		} else { //double in right column
			if(lWantsCCW) {
				if(gFallingDouble.column >= 0 &&
				   !isBothRowsOccupied(gFallingDouble.column, lUnitY + 1) &&
				   !isMostlyOccupied(gFallingDouble.column, lUnitY)) {
					gFallingDouble.rotateCounterClockwise();
				} else if(gFallingDouble.column < gGameGrid.width - 2 &&
				          !isMostlyOccupied(gFallingDouble.column + 2, lUnitY + 1)) {
					gFallingDouble.x += gameArea.bubbleSize;
					gFallingDouble.column += 1;
					gFallingDouble.rotateCounterClockwise();
				}
			} else {
				if(gFallingDouble.column >= 0 &&
				   !isMostlyOccupied(gFallingDouble.column, lUnitY + 1)) {
					gFallingDouble.rotateClockwise();
				} else if(gFallingDouble.column < gGameGrid.width - 2 &&
				          !isBothRowsOccupied(gFallingDouble.column + 2, lUnitY + 1) &&
				          !isMostlyOccupied(gFallingDouble.column + 2, lUnitY)) {
					gFallingDouble.x += gameArea.bubbleSize;
					gFallingDouble.column += 1;
					gFallingDouble.rotateClockwise();
				}
			}
		}
	} else { // double is horizontal
		if(lWantsCCW) {
			if(!isBothRowsOccupied(gFallingDouble.column, lUnitY) &&
			   !isMostlyOccupied(gFallingDouble.column + 1, lUnitY)) {
				gFallingDouble.rotateCounterClockwise();
			}
		} else {
			if(!isBothRowsOccupied(gFallingDouble.column + 1, lUnitY) &&
			   !isMostlyOccupied(gFallingDouble.column, lUnitY)) {
				gFallingDouble.rotateClockwise();
			}
		}
	}
}

function findMinX() {
	function findMinXForRow(pX, pY, pHigh) {
		var lRow = pHigh ? Math.ceil(pY): Math.floor(pY);
		for(var i = Math.floor(pX); i >= 0; --i) {
			if(gGameGrid.valueAt(lRow, i)) {
				return i + Math.sqrt(1 - Math.pow(pY-lRow, 2))
			}
		}
		return 0;
	}
	var leftX = gFallingDouble.x/gameArea.bubbleSize + gFallingDouble.leftColumn
	var leftY = gFallingDouble.y/gameArea.bubbleSize + gFallingDouble.leftRow
	var rightX = gFallingDouble.x/gameArea.bubbleSize + gFallingDouble.rightColumn
	var rightY = gFallingDouble.y/gameArea.bubbleSize + gFallingDouble.rightRow

	var lMinX = findMinXForRow(leftX, leftY, false) - gFallingDouble.leftColumn;
	lMinX = Math.max(lMinX, findMinXForRow(leftX, leftY, true) - gFallingDouble.leftColumn);
	lMinX = Math.max(lMinX, findMinXForRow(rightX, rightY, false) - gFallingDouble.rightColumn);
	lMinX = Math.max(lMinX, findMinXForRow(rightX, rightY, true) - gFallingDouble.rightColumn);
	return lMinX*gameArea.bubbleSize;
}

function findMaxX() {
	function findMaxXForRow(pX, pY, pHigh) {
		var lRow = pHigh ? Math.ceil(pY): Math.floor(pY);
		for(var i = Math.ceil(pX); i < gGameGrid.width; ++i) {
			if(gGameGrid.valueAt(lRow, i)) {
				return i - Math.sqrt(1 - Math.pow(pY-lRow, 2))
			}
		}
		return gGameGrid.width - 1;
	}
	var leftX = gFallingDouble.x/gameArea.bubbleSize + gFallingDouble.leftColumn
	var leftY = gFallingDouble.y/gameArea.bubbleSize + gFallingDouble.leftRow
	var rightX = gFallingDouble.x/gameArea.bubbleSize + gFallingDouble.rightColumn
	var rightY = gFallingDouble.y/gameArea.bubbleSize + gFallingDouble.rightRow

	var lMaxX = findMaxXForRow(leftX, leftY, false) - gFallingDouble.leftColumn;
	lMaxX = Math.min(lMaxX, findMaxXForRow(leftX, leftY, true) - gFallingDouble.leftColumn);
	lMaxX = Math.min(lMaxX, findMaxXForRow(rightX, rightY, false) - gFallingDouble.rightColumn);
	lMaxX = Math.min(lMaxX, findMaxXForRow(rightX, rightY, true) - gFallingDouble.rightColumn);
	return lMaxX*gameArea.bubbleSize;
}

function shouldStopFalling(pColumn, pY, pSingle, pRotation) {
	var lNextRow = Math.floor(pY/gameArea.bubbleSize) + 1;
	if(lNextRow === gGameGrid.height) {
		return true;
	}

	if(pSingle || pRotation === 270) {
		return Boolean(gGameGrid.valueAt(lNextRow, pColumn));
	} else {
		switch(pRotation) {
		case 0:
			return Boolean(gGameGrid.valueAt(lNextRow, pColumn)) ||
			       Boolean(gGameGrid.valueAt(lNextRow, pColumn + 1));
		case 90:
			return lNextRow + 1 === gGameGrid.height ||
			       Boolean(gGameGrid.valueAt(lNextRow + 1, pColumn));
		case 180:
			return Boolean(gGameGrid.valueAt(lNextRow, pColumn)) ||
			       Boolean(gGameGrid.valueAt(lNextRow, pColumn - 1));
		}
	}
}

function updateTimestamp() {
	gLastFallUpdate = Date.now();
	gSpeedAddition = 0;
	gDragSpeedX = 0;
}

function animateFallingBubbles() {
	var lNewTime = Date.now();
	var lTimeDiff = lNewTime - gLastFallUpdate;
	var lBubble; var i;

	// destroy bubbes after they are finished with their pop sequence
	for(i = 0; i < gPoppingBubbles.length; ++i) {
		lBubble = gPoppingBubbles[i];
		if(lBubble.state === "KillMe") {
			killKillKill(lBubble);
			gPoppingBubbles.splice(i, 1);
			i--;
		}
	}

	if(gPoppingBubbles.length === 0 && game.remainingMonkeys <= 0) {
		nextLevelText2.text = game.remainingTime + " seconds remaining, ";
		if(gLevelModel.recordHighscore(game.level, game.remainingTime)) {
			nextLevelText2.text += "new high score!";
		} else {
			nextLevelText2.text += "well done!";
		}
		gLevelModel.registerCompleted(game.level);
		if(game.level === gLevels.length - 1) {
			gameOverText1.text = "All levels completed!";
			gameOverText2.text = nextLevelText2.text;
			game.state = "Game Over";
		} else {
			nextLevelText1.text = "Level " + (game.level + 1) + " completed!";
			game.state = "Next Level";
		}
	}

	if(gameArea.state === "Double Falling") {
		gFallingDouble.y += Math.min(gameArea.bubbleSize, (gameArea.fallSpeed + gSpeedAddition)*lTimeDiff);
		gSpeedAddition /= 1.07;

		if(gFallingDouble.y > 2*gameArea.bubbleSize && !gameArea.newDoubleReady && !gameArea.bringInClaws.running) {
			gameArea.bringInClaws.start();
		}

		// check for downward stop before moving sideways, if dragging is active it can move double far away sideways to
		// avoid having the double on top of a bubble (collision avoidance), so we need to be determine if we're
		// landing on a bubble first, otherwise we will "slide" down on the side of it.
		if(shouldStopFalling(gFallingDouble.column + gFallingDouble.leftColumn,
		                     gFallingDouble.y + gFallingDouble.leftRow*gameArea.bubbleSize,
		                     false, gFallingDouble.angle)) {
			if(gFallingDouble.state === "Dragging") {
				gFallingDouble.x = gFallingDouble.column * gameArea.bubbleSize;
			}
			onDoubleLanding();
		} else if(gFallingDouble.state === "Dragging") {
			gFilteredFingerX += gDragSpeedX*lTimeDiff;
			var lDiff = gFilteredFingerX - gDragStartX - (gFallingDouble.x - gBubbleDragStartX);
			if(lDiff > gameArea.bubbleSize) {
				gDragStartX += lDiff - gameArea.bubbleSize;
			}
			else if(lDiff < -gameArea.bubbleSize) {
				gDragStartX += lDiff + gameArea.bubbleSize;
			}

			var lDragDestinationX = (gFilteredFingerX - gDragStartX) + gBubbleDragStartX;
			var lMinX = findMinX();
			var lMaxX = findMaxX();
			if(lDragDestinationX < lMinX) {
				gFallingDouble.x = lMinX;
			} else if (lDragDestinationX > lMaxX) {
				gFallingDouble.x = lMaxX;
			} else {
				gFallingDouble.x = lDragDestinationX;
			}
			gFallingDouble.column = Math.round(gFallingDouble.x/gameArea.bubbleSize);
		}
	} else if(gameArea.state === "Fall Pop") {
		var lSomethingLanded = false;
		for(i = 0; i < gFallingBubbles.length; ++i) {
			lBubble = gFallingBubbles[i];
			lBubble.y += Math.min(gameArea.bubbleSize, gameArea.sequenceFallSpeed*lTimeDiff);

			if(shouldStopFalling(lBubble.column, lBubble.y, lBubble.single, lBubble.bubbleRotation)) {
				lBubble.state = "";
				lBubble.row = Math.floor(lBubble.y/gameArea.bubbleSize);
				lBubble.y = Qt.binding(function(){return gameArea.bubbleSize*lBubble.row});
				gGameGrid.setValueAt(lBubble.row, lBubble.column, lBubble)
				gFallingBubbles.splice(i, 1);
				i--;
				lSomethingLanded = true;
			}
		}
		if(lSomethingLanded) {
			checksAfterLanding();
		}
	}
	gLastFallUpdate = lNewTime;
}

function checksAfterLanding() {
	function isChoked() {
		for(var i = 0; i < gameArea.gameColumnCount; ++i) {
			if(gGameGrid.valueAt(1, i))
				return true;
		}
		return false;
	}

	checkForQuads();
	checkForLooseBubbles();
	if(gFallingBubbles.length > 0) {
		gameArea.state = "Fall Pop"
	} else {
		if(isChoked()) {
			game.state = "Game Over";
			gameOverText1.text = "Game over.";
			gameOverText2.text = "You choked!";
		} else if(!gameArea.newDoubleReady) {
			if(!gameArea.bringInClaws.running) {
				gameArea.bringInClaws.start();
			}
			gameArea.state = "Waiting for New Double";
		} else {
			startDoubleFalling();
		}
	}
}

function onDoubleLanding() {
	gSpeedAddition = 0;
	var lRow = Math.floor(gFallingDouble.y/gameArea.bubbleSize);
	var lCol = gFallingDouble.column;

	createNewBubble(lRow + gFallingDouble.leftRow,
	                lCol + gFallingDouble.leftColumn,
	                false, false, gFallingDouble.angle,
	                gFallingDouble.leftBubble.color, false);
	createNewBubble(lRow + gFallingDouble.rightRow,
	                lCol + gFallingDouble.rightColumn,
	                false, false, (gFallingDouble.angle + 180) % 360,
	                gFallingDouble.rightBubble.color, false);
	killKillKill(gFallingDouble);
	gFallingDouble = null;
	gBlockCounter++;
	checksAfterLanding();
}

function startDoubleFalling() {
	gFallingDouble = gNextFallingDouble;
	gNextFallingDouble = null;
	gFallingDouble.state = "Falling"
	gameArea.state = "Double Falling";
	gameArea.bringOutClaws.start();
	gameArea.newDoubleReady = false;
}

var gBubbleComponent = null;
function createNewBubble(pRow, pColumn, pSingle, pHasMonkey, pRotation, pColor, pStartHidden) {
	if(!gBubbleComponent) {
		gBubbleComponent = Qt.createComponent("Bubble.qml");
	}
	var properties = {
		"row": pRow,
		"column": pColumn,
		"hasMonkey": pHasMonkey,
		"bubbleRotation": pRotation,
		"color": pColor,
		"single": pSingle
	}

	var dynamicObject = gBubbleComponent.createObject(gameArea, properties);
	if (dynamicObject === null) {
		console.log("error creating bubble");
		console.log(gBubbleComponent.errorString());
		return;
	}
	if(pStartHidden) {
		dynamicObject.startHidden();
	}
	gGameGrid.setValueAt(pRow, pColumn, dynamicObject);
}

var gDoubleComponent = null;
function createNewFallingDouble() {
	if(!gDoubleComponent) {
		gDoubleComponent = Qt.createComponent("DoubleBubble.qml");
	}
	var properties = {
		"x": (gameArea.gameColumnCount/2 - 1)*gameArea.bubbleSize,
		"column": gameArea.gameColumnCount/2 - 1,
		"leftBubble.color": gColors[Math.floor(Math.random() * gLevels[game.level].colorCount)],
		"rightBubble.color": gColors[Math.floor(Math.random() * gLevels[game.level].colorCount)],
		"leftBubble.x": -(gameArea.gameColumnCount/2)*gameArea.bubbleSize,
		"rightBubble.x": (gameArea.gameColumnCount/2 + 1)*gameArea.bubbleSize
	}
	var dynamicObject = gDoubleComponent.createObject(gameArea, properties);
	if (dynamicObject === null) {
		console.log("error creating block");
		console.log(gDoubleComponent.errorString());
		return false;
	}

	gNextFallingDouble = dynamicObject;
}

function clearAllBubbles() {
	if(gNextFallingDouble !== null) {
		killKillKill(gNextFallingDouble);
		gNextFallingDouble = null;
	}
	if(gFallingDouble !== null) {
		killKillKill(gFallingDouble);
		gFallingDouble = null;
	}

	if(gGameGrid) {
		for(var r = 0; r < gGameGrid.height; ++r) {
			for(var c = 0; c < gGameGrid.width; ++c) {
				killKillKill(gGameGrid.valueAt(r,c));
				gGameGrid.setValueAt(r, c, null);
			}
		}
	}
	for(var i = 0; i < gFallingBubbles.length; ++i) {
		killKillKill(gFallingBubbles[i]);
	}
	gFallingBubbles = [];
}

function createNewGameGrid(pMonkeyCount, pEmptyRows) {
	var lPossibleRowCount = gameArea.gameRowCount - pEmptyRows;
	var lDestinations = new Array(lPossibleRowCount * gameArea.gameColumnCount)
	for(var r = 0; r < lPossibleRowCount; ++r) {
		for(var c = 0; c < gameArea.gameColumnCount; ++c) {
			lDestinations[r*gameArea.gameColumnCount + c] = {row: r + pEmptyRows, col: c};
		}
	}

	gGameGrid = new Grid(gameArea.gameColumnCount, gameArea.gameRowCount);
	for(var i = 0; i < pMonkeyCount; ++i) {
		var lDest = lDestinations.splice(Math.floor(Math.random()*lDestinations.length), 1);
		createNewBubble(lDest[0].row, lDest[0].col, true, true, 0, gColors[Math.floor(Math.random() * gLevels[game.level].colorCount)], true);
	}
	return true;
}

function startNewGame(pLevel) {
// ensure that there's some empty space at the top of game area.
	var lEmptyRows = 5;
// if screen is too wide we could get very few game rows... don't allow that
	var lMinimumRows = 10;

	clearAllBubbles();
	game.level = pLevel;
	gBlockCounter = 0;

	gameArea.gameColumnCount = gLevels[game.level].columnCount;
	var lDesiredBubbleSize = Math.floor(windowWidth/gameArea.gameColumnCount) // desired to make the bubbles fill entire screen width
	var lAvailableHeight = game.windowHeight - bottomBar.height - bottomBar.border.width;
	gameArea.gameRowCount = Math.max(lMinimumRows, Math.ceil(lAvailableHeight/lDesiredBubbleSize))
	var lMonkeyCount = Math.round(gameArea.gameColumnCount*(gameArea.gameRowCount - lEmptyRows)*gLevels[game.level].monkeyDensity/100.0);
	createNewGameGrid(lMonkeyCount, lEmptyRows);
	game.remainingMonkeys = lMonkeyCount;
	game.remainingTime = gLevels[game.level].initialTime;
	game.visibleRemainingTime= Math.min(gLevels[game.level].initialTime, timeBar.maxTime);
	game.state = "Running";
	gameArea.state = "Waiting for New Double";
	gameArea.bringInClaws.restart();
}

function decreaseRemainingTime() {
	game.remainingTime--;
	if(game.remainingTime < game.visibleRemainingTime) {
		game.visibleRemainingTime = game.remainingTime;
	}

	if(game.remainingTime <= 0) {
		game.state = "Game Over";
		gameOverText1.text = "Game over.";
		gameOverText2.text = "Time's up!";
	}
}

function checkForQuads() {
	function popBubble(pRow, pColumn) {
		var lBubble = gGameGrid.valueAt(pRow, pColumn);
		if(lBubble.state === "Popping") {
			return;
		}
		lBubble.state = "Popping";
		if(!lBubble.single) {
			var lOtherBubble;
			switch(lBubble.bubbleRotation) {
			case 0:
				lOtherBubble = gGameGrid.valueAt(pRow, pColumn + 1);
				break;
			case 90:
				lOtherBubble = gGameGrid.valueAt(pRow + 1, pColumn);
				break;
			case 180:
				lOtherBubble = gGameGrid.valueAt(pRow, pColumn - 1);
				break;
			case 270:
				lOtherBubble = gGameGrid.valueAt(pRow - 1, pColumn);
				break;
			}
			lOtherBubble.single = true;
		}
		if(lBubble.hasMonkey) {
			game.remainingMonkeys--;
			game.remainingTime += gLevels[game.level].monkeyValue;
		}
	}

	function checkColumnPop(pCount, pRow, pCol) {
		if(pCount > 3) {
			for(var rc = pCol - 1; rc >= pCol - pCount; --rc) {
				popBubble(pRow, rc);
			}
		}
	}

	function checkRowPop(pCount, pRow, pCol) {
		if(pCount > 3) {
			for(var rr = pRow - 1; rr >= pRow - pCount; --rr) {
				popBubble(rr, pCol);
			}
		}
	}

	var lCount = 0;
	var lColor;
	for(var r = 0; r < gGameGrid.height; ++r) {
		for(var c = 0; c < gGameGrid.width; ++c) {
			if(gGameGrid.valueAt(r,c)) {
				if(lCount === 0 || gGameGrid.valueAt(r,c).color !== lColor) {
					checkColumnPop(lCount, r, c);
					lCount = 1;
					lColor = gGameGrid.valueAt(r,c).color;
				} else {
					// same color as last
					lCount++;
				}
			} else {
				checkColumnPop(lCount, r, c);
				lCount = 0;
			}
		}
		checkColumnPop(lCount, r, c);
		lCount = 0;
	}

	lCount = 0;
	for(c = 0; c < gGameGrid.width; ++c) {
		for(r = 0; r < gGameGrid.height; ++r) {
			if(gGameGrid.valueAt(r,c)) {
				if(lCount === 0 || gGameGrid.valueAt(r,c).color !== lColor) {
					checkRowPop(lCount, r, c);
					lCount = 1;
					lColor = gGameGrid.valueAt(r,c).color;
				} else {
					// same color as last
					lCount++;
				}
			} else {
				checkRowPop(lCount, r, c);
				lCount = 0;
			}
		}
		checkRowPop(lCount, r, c);
		lCount = 0;
	}

	for(c = gGameGrid.width - 1; c >= 0; --c) {
		for(r = gGameGrid.height - 1; r >= 0; --r) {
			var lBubble = gGameGrid.valueAt(r,c);
			if(lBubble && lBubble.state === "Popping") {
				lBubble.popDelay = Math.floor(Math.random() * 400);
				if(lBubble.hasMonkey) {
					var lBarXDest = Math.min(timeBar.width - gameArea.bubbleSize/2 + game.timeInFlight*timeBar.pixelsPerSecond,
					                         timeBar.maxTime*timeBar.pixelsPerSecond);
					var lDest = lBubble.mapFromItem(timeBar, lBarXDest, timeBar.height - gameArea.bubbleSize);
					lBubble.monkeyFlightX.to = lDest.x;
					lBubble.monkeyFlightY.to = lDest.y;
					var lDuration = 1700*Math.sqrt(Math.pow(lDest.x, 2) + Math.pow(lDest.y, 2))/gameArea.height;
					lBubble.monkeyFlightX.duration = lDuration;
					lBubble.monkeyFlightY.duration = lDuration;
					game.timeInFlight += gLevels[game.level].monkeyValue;
				}
				lBubble.popSequence.start();
				gPoppingBubbles.push(lBubble);
				gGameGrid.setValueAt(r, c, null);
			}
		}
	}
}

function checkForLooseBubbles() {
	function makeBubbleFall(pRow, pColumn) {
		var lBubble = gGameGrid.valueAt(pRow, pColumn);
		lBubble.state = "Falling";
		for(var i = 0; i < gFallingBubbles.length; ++i) {
			if(gFallingBubbles[i].y < lBubble.y) {
				break;
			}
		}
		gFallingBubbles.splice(i, 0, lBubble);
		gGameGrid.setValueAt(pRow, pColumn, null);
	}

	for(var r = gGameGrid.height - 2; r >= 0; --r) {
		for(var c = 0; c < gGameGrid.width; ++c) {
			if(!gGameGrid.valueAt(r,c)) {
				continue;
			}
			var lSetFalling = false;
			var lBubble = gGameGrid.valueAt(r,c);
			var lBubbleBelow = gGameGrid.valueAt(r+1, c);
			if(!lBubble.hasMonkey && (!lBubbleBelow || (lBubbleBelow && lBubbleBelow.state === "Falling"))) {
				if(lBubble.single) {
					lSetFalling = true;
				} else {
					if(lBubble.bubbleRotation === 90 || lBubble.bubbleRotation === 270) {
						lSetFalling = true;
					} else {
						var lSideBelow;
						if(lBubble.bubbleRotation === 0) {
							lSideBelow = gGameGrid.valueAt(r+1, c+1);
						} else {
							lSideBelow = gGameGrid.valueAt(r+1, c-1);
						}
						if(!lSideBelow || (lSideBelow && lSideBelow.state === "Falling")) {
							lSetFalling = true;
						}
					}
				}
			}
			if(lSetFalling){
				makeBubbleFall(r, c);
			}
		}
	}
}

