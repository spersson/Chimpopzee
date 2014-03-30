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
	Component {
		id: splashEmitter
		Particles {
			lifeSpan: 175; lifeSpanDeviation: 200
			velocity: windowHeight/4; velocityDeviation: windowHeight/5
			angleDeviation: 360
			emissionRate: 0
		}
	}

	Component {
		id: starEmitter
		Particles {
			lifeSpan: 600; lifeSpanDeviation: 600
			velocity: windowHeight/5; velocityDeviation: windowHeight/5
			angle: -90; angleDeviation: 180
			emissionRate: 0
		}
	}

	Loader {
		id: _splash1
	}

	Loader {
		id: _splash2
	}

	Loader {
		id: _stars1
	}

	Loader {
		id: _stars2
	}

	Loader {
		id: _stars3
	}

	Component.onCompleted: {
		_splash1.sourceComponent = splashEmitter
		_splash1.item.source = "qrc:///particles/splash1"
		_splash2.sourceComponent = splashEmitter
		_splash2.item.source = "qrc:///particles/splash2"

		_stars1.sourceComponent = starEmitter
		_stars1.item.source = "qrc:///particles/redStar"
		_stars2.sourceComponent = starEmitter
		_stars2.item.source = "qrc:///particles/yellowStar"
		_stars3.sourceComponent = starEmitter
		_stars3.item.source = "qrc:///particles/blueStar"
	}

	function splashBubble(coords) {
		_splash1.item.x = coords.x
		_splash1.item.y = coords.y
		_splash2.item.x = coords.x
		_splash2.item.y = coords.y
		_splash1.item.burst(8);
		_splash2.item.burst(8);
	}

	function burstStars(coords) {
		_stars1.item.x = coords.x
		_stars1.item.y = coords.y
		_stars2.item.x = coords.x
		_stars2.item.y = coords.y
		_stars3.item.x = coords.x
		_stars3.item.y = coords.y
		_stars1.item.burst(10);
		_stars2.item.burst(10);
		_stars3.item.burst(10);
	}
}

