// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
	id: imageButton
	signal clicked
	property alias source: image.source

	height: 50
	// width set to preserve aspect ratio
	width: height*image.sourceSize.width/image.sourceSize.height
	scale: mouseArea.pressed ? 0.9 : 1.0
	Behavior on scale { NumberAnimation { duration: 50 } }

	MouseArea {
		id: mouseArea
		anchors.fill: imageButton
		onClicked: imageButton.clicked()
	}

	Image {
		id: image
		height: imageButton.height
		// width set to preserve aspect ratio
		width: height*sourceSize.width/sourceSize.height
		anchors.centerIn: parent
		smooth: true
	}
}
