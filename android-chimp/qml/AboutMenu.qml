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
			text: "Chimpopzee v2.0"
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: windowHeight/20
		}
		Text{
			text:"Copyright Simon Persson 2012-2014. Source code licensed under the GNU General Public License (GPL) version 2 or later.\n" +
			     "Chimp icon by Jakub Steiner. All graphics are licensed under creative commons by-sa (attribution, share-alike) v2.0.\n" +
			     "Source code available at:\nhttps://github.com/spersson/Chimpopzee"
			width: parent.width
			wrapMode: Text.Wrap
			font.pixelSize: windowHeight/48
		}
		ImageButton {
			source: "qrc:///buttons/mainMenu"
			onClicked: game.state = "Main Menu"
		}
	}
}
