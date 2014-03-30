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
import "tutorial.js" as TutorialContent

MenuCard {
	property int pageNumber: 1

	Column {
		anchors {
			margins: windowHeight/32
			top: parent.top
			left: parent.left; right: parent.right
		}
		spacing: windowHeight/48

		Image {
			source: TutorialContent.images[pageNumber - 1]
			anchors.horizontalCenter: parent.horizontalCenter
			height: windowHeight/2.5
			width: height*sourceSize.width/sourceSize.height
		}
		Text{
			text: TutorialContent.texts[pageNumber - 1]
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
				anchors.horizontalCenter: undefined
				width: naturalWidth
				opacity: pageNumber != 1 ? 1 : 0.2
				onClicked: if(pageNumber > 1) pageNumber--;
			}
			Text {
				text: pageNumber + "/" + TutorialContent.texts.length
				anchors.verticalCenter: parent.verticalCenter
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: windowHeight/32
			}
			ImageButton {
				source: "qrc:///buttons/next"
				anchors.horizontalCenter: undefined
				width: naturalWidth
				opacity: pageNumber != TutorialContent.texts.length ? 1 : 0.2
				onClicked: if(pageNumber < TutorialContent.texts.length) pageNumber++;
			}
		}
		ImageButton {
			source: "qrc:///buttons/mainMenu"
			onClicked: { game.state = "Main Menu" }
		}
	}
}
