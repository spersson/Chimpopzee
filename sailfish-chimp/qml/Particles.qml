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
import QtQuick.Particles 2.0

ParticleSystem {
	Emitter {
		id: splashEmitter
		group: "splash"
		lifeSpan: 175; lifeSpanVariation: 100
		velocity: AngleDirection {
			angleVariation: 180
			magnitude: windowHeight/4; magnitudeVariation: windowHeight/10
		}
		emitRate: 0
	}

	Emitter {
		id: starEmitter
		group: "stars"
		lifeSpan: 600; lifeSpanVariation: 300
		velocity: AngleDirection {
			magnitude: windowHeight/5; magnitudeVariation: windowHeight/10
			angle: -90; angleVariation: 90
		}
		emitRate: 0
	}

	ImageParticle {
		source: "qrc:///particles/splash1"
		rotationVariation: 90
		groups: ["splash"]
	}

	ImageParticle {
		source: "qrc:///particles/yellowStar"
		groups: ["stars"]
		colorVariation: 0.8
	}

	function splashBubble(coords) {
		splashEmitter.burst(15, coords.x, coords.y);
	}

	function burstStars(coords) {
		starEmitter.burst(30, coords.x, coords.y);
	}
}

