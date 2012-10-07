// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
	width: windowWidth*7/8
	height: windowHeight*3/4
	radius: height/12
	border.width: 0.02*screen.dpi
	border.color: "#534333"
	color: "#f9eec3"
	anchors {
		margins: 0.02*screen.dpi
		verticalCenter: parent.verticalCenter
	}
}
