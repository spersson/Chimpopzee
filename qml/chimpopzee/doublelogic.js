function rotateOnLeftBubble() {
	_leftBubble.x = _leftBubble.column*gameArea.bubbleSize;
	_leftBubble.y = _leftBubble.row*gameArea.bubbleSize;
	_rightBubble.x = function(){return _leftBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*_leftBubble.bubbleRotation/180)};
	_rightBubble.y = function(){return _leftBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*_leftBubble.bubbleRotation/180)};
}

function rotateOnRightBubble() {
	_rightBubble.x = _rightBubble.column*gameArea.bubbleSize;
	_rightBubble.y = _rightBubble.row*gameArea.bubbleSize;
	_leftBubble.x = function(){return _rightBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*_rightBubble.bubbleRotation/180)};
	_leftBubble.y = function(){return _rightBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*_rightBubble.bubbleRotation/180)};
}

function slideOnRightBubble() {
	_leftBubble.x = _leftBubble.column*gameArea.bubbleSize;
	_leftBubble.y = function(){return _rightBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*_rightBubble.bubbleRotation/180)};
	_rightBubble.x = function(){return _leftBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*_leftBubble.bubbleRotation/180)};
}

function slideOnLeftBubble() {
	_rightBubble.x = _rightBubble.column*gameArea.bubbleSize;
	_rightBubble.y = function(){return _leftBubble.y + gameArea.bubbleSize*Math.sin(Math.PI*_leftBubble.bubbleRotation/180)};
	_leftBubble.x = function(){return _rightBubble.x + gameArea.bubbleSize*Math.cos(Math.PI*_rightBubble.bubbleRotation/180)};
}

function rotateClockwise() {
	switch(angle) {
	case 0:
		rotateOnRightBubble();
		_leftBubble.row = 0;
		_leftBubble.column = 1;
		break;
	case 90:
		if(_rightBubble.column === 0) {
			rotateOnRightBubble();
			_leftBubble.row = 1;
			_leftBubble.column = 1
		} else {
			slideOnRightBubble();
			_leftBubble.row = 1;
			_rightBubble.column = 0;
		}
		break;
	case 180:
		rotateOnLeftBubble();
		_rightBubble.row = 0;
		_rightBubble.column = 1;
		break;
	case 270:
		if(_leftBubble.column === 0) {
			rotateOnLeftBubble();
			_rightBubble.row = 1;
			_rightBubble.column = 1
		} else {
			slideOnLeftBubble();
			_rightBubble.row = 1;
			_leftBubble.column = 0;
		}
		break;
	}
	angle = (angle + 90) % 360;
}

function rotateCounterClockwise() {
	switch(angle) {
	case 0:
		rotateOnLeftBubble();
		_rightBubble.row = 0;
		_rightBubble.column = 0;
		break;
	case 90:
		if(_rightBubble.column === 1) {
			rotateOnRightBubble();
			_leftBubble.row = 1;
			_leftBubble.column = 0
		} else {
			slideOnRightBubble();
			_leftBubble.row = 1;
			_rightBubble.column = 1;
		}
		break;
	case 180:
		rotateOnRightBubble();
		_leftBubble.row = 0;
		_leftBubble.column = 0;
		break;
	case 270:
		if(_leftBubble.column === 1) {
			rotateOnLeftBubble();
			_rightBubble.row = 1;
			_rightBubble.column = 0
		} else {
			slideOnLeftBubble();
			_rightBubble.row = 1;
			_leftBubble.column = 1;
		}
		break;
	}
	angle = (angle + 270) % 360;
}
