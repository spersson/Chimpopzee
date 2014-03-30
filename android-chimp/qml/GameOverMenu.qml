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

MenuCard {
	Column {
		anchors {
			margins: windowHeight/32
			verticalCenter: parent.verticalCenter
			left: parent.left; right: parent.right
		}
		spacing: windowHeight/16

		Text{
			text: game.gameOverCaption
			width: parent.width
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: windowHeight/24
		}
		Text{
			text: game.gameOverMessage
			width: parent.width
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: windowHeight/32
		}
		ImageButton {
			source: "qrc:///buttons/restart"
			onClicked: game.restartLevel()
		}
		ImageButton {
			source: "qrc:///buttons/mainMenu"
			onClicked: game.returnToMainMenu()
		}
	}
}
